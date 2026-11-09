import 'package:flutter/material.dart';
import '../../../core/localization/l10n.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';

class PlayerStatusOverlay extends StatelessWidget {
  const PlayerStatusOverlay(
      {super.key,
      required this.loading,
      this.errorCode,
      required this.onRetry,
      required this.onBack});
  final bool loading;
  final String? errorCode;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.appTheme.scrim(.85),
        child: Center(
            child: Semantics(
                liveRegion: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (loading &&
                              !MediaQuery.disableAnimationsOf(context))
                            const CircularProgressIndicator()
                          else
                            Icon(
                                loading ? AppIcons.movie : AppIcons.imageBroken,
                                size: 48),
                          const SizedBox(height: 24),
                          Text(
                              loading
                                  ? context.l10n.playerLoading
                                  : errorCode == 'missing'
                                      ? context.l10n.detailsMissingFile
                                      : context.l10n.playerLoadFailed,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center),
                          if (!loading) ...[
                            const SizedBox(height: 12),
                            Text(context.l10n.playerLoadFailedBody,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            Wrap(spacing: 12, children: [
                              OutlinedButton(
                                  onPressed: onBack,
                                  child: Text(context.l10n.playerBack)),
                              FilledButton(
                                  onPressed: onRetry,
                                  child: Text(context.l10n.commonRetry)),
                            ]),
                          ],
                        ],
                      )),
                ))),
      );
}
