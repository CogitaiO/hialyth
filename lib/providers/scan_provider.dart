import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_provider.dart';
import '../data/services/file_discovery_service.dart';

class ScanState {
  const ScanState(
      {this.running = false,
      this.completed = 0,
      this.total = 0,
      this.errors = const [],
      this.warnings = 0,
      this.cancelled = false});
  final bool running;
  final int completed;
  final int total;
  final List<String> errors;
  final int warnings;
  final bool cancelled;
}

final scanProvider = StateNotifierProvider<ScanController, ScanState>(
    (ref) => ScanController(ref.watch(scannerProvider)));

class ScanController extends StateNotifier<ScanState> {
  ScanController(this._scanner) : super(const ScanState());
  final FileDiscoveryService _scanner;
  bool _cancel = false;
  void cancel() {
    _cancel = true;
  }

  Future<ScanState> scan(List<String> folders) async {
    if (state.running) return state;
    _cancel = false;
    var completed = 0;
    var warnings = 0;
    final errors = <String>[];
    final roots = folders.toSet().toList();
    state = ScanState(running: true, total: roots.length);
    for (final folder in roots) {
      if (_cancel || !mounted) break;
      try {
        final result = await _scanner.scanAndGroupFiles(folder,
            isCancelled: () => _cancel || !mounted);
        warnings += result.warnings.length;
      } catch (_) {
        errors.add(folder);
      }
      completed++;
      if (!mounted) return const ScanState(cancelled: true);
      state = ScanState(
          running: !_cancel,
          completed: completed,
          total: roots.length,
          errors: List.unmodifiable(errors),
          warnings: warnings,
          cancelled: _cancel);
    }
    if (!mounted) return const ScanState(cancelled: true);
    return state = ScanState(
        completed: completed,
        total: roots.length,
        errors: List.unmodifiable(errors),
        warnings: warnings,
        cancelled: _cancel);
  }

  @override
  void dispose() {
    _cancel = true;
    super.dispose();
  }
}
