import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';
import '../../../theme/app_theme_extension.dart';

class CollectionDialog extends StatefulWidget {
  const CollectionDialog({
    super.key,
    required this.collections,
    required this.accentColor,
    required this.onSave,
  });

  final List<String> collections;
  final Color accentColor;
  final Future<void> Function(String name) onSave;

  @override
  State<CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<CollectionDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Animation<double>? _routeAnimation;
  bool _focusRequested = false;
  bool _saving = false;
  bool _saveFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (!identical(animation, _routeAnimation)) {
      _routeAnimation?.removeStatusListener(_onRouteStatus);
      _routeAnimation = animation;
      animation?.addStatusListener(_onRouteStatus);
    }
    if (animation == null || animation.status == AnimationStatus.completed) {
      _requestInitialFocus();
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _requestInitialFocus();
  }

  void _requestInitialFocus() {
    if (_focusRequested) return;
    _focusRequested = true;
    // Avoid overlapping the keyboard and route entrance animations.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (_saving || name.isEmpty) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.onSave(name);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return AlertDialog(
      scrollable: true,
      backgroundColor: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      title: Text(context.l10n.detailsCollection),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const ValueKey('collection-name'),
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_saving,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: context.l10n.detailsNewCollection,
                errorText: _saveFailed ? context.l10n.commonSaveFailed : null,
              ),
            ),
            if (widget.collections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.detailsChooseCollection,
                style: TextStyle(color: tokens.textMuted, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  key: const ValueKey('collection-options'),
                  itemCount: widget.collections.length,
                  itemBuilder: (context, index) {
                    final name = widget.collections[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: _saving
                          ? null
                          : () => _controller.value = TextEditingValue(
                              text: name,
                              selection: TextSelection.collapsed(
                                offset: name.length,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.dialogCancel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => ElevatedButton(
            key: const ValueKey('collection-save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
            ),
            onPressed: _saving || value.text.trim().isEmpty ? null : _submit,
            child: Text(context.l10n.dialogAdd),
          ),
        ),
      ],
    );
  }
}
