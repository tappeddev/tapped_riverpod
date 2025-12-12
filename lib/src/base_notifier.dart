import 'dart:async';

import 'package:async/async.dart' show CancelableOperation;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';

/// Base class for custom Notifiers that provides:
/// - cancelable async operations
/// - standardized error handling
/// - helper for loading/success/failure Result states
abstract class BaseNotifier<T> extends Notifier<T> {
  late final CatchingExecutor _catchingExecutor;

  /// The error logger that is used from [CatchingExecutor].
  /// This can be overridden in:
  ///   ProviderScope(
  ///     overrides: BaseNotifier.errorLogger.overrideWithValue(myNewLogger),
  ///     ...
  ///   )
  static Provider<OperationErrorLogger> get errorLogger => _errorLogger;

  @visibleForTesting
  Map<String, CancelableOperation<void>> get operations =>
      _catchingExecutor.operations;

  @mustCallSuper
  @override
  T build() {
    _catchingExecutor = CatchingExecutor(errorLogger: ref.read(_errorLogger));

    // register cleanup when provider is disposed
    ref.onDispose(() {
      _catchingExecutor.cancelAllOperations();

      onDispose();
    });

    return init();
  }

  @protected
  T init();

  /// Runs the code in [call].
  /// This method returns null if the operation failed.
  @protected
  @visibleForTesting
  Future<R?> runCatching<R>(
    Future<R> Function() call, {
    required String identifier,
    required void Function(Result<R> result) setState,
    void Function()? onCancel,
  }) async {
    return _catchingExecutor.execute(
      identifier: identifier,
      task: call,
      setState: (result) {
        if (!ref.mounted) return;

        setState(result);
      },
      onCancel: onCancel,
    );
  }

  void cancelRunCatchingBy({required String identifier}) {
    _catchingExecutor.cancelOperationBy(identifier: identifier);
  }

  /// Create a [CancelableOperation] that will automatically canceled when [cancelAllOperations] is called.
  /// [O] represents the generic type of the operation.
  @protected
  CancelableOperation<O> createOperation<O>(
    Future<O> result, {
    FutureOr<void> Function()? onCancel,
    String? overrideIdentifier,
  }) {
    return _catchingExecutor.createOperation<O>(
      result,
      overrideIdentifier: overrideIdentifier,
      onCancel: onCancel,
    );
  }

  void onDispose() {}
}

final _errorLogger = Provider<OperationErrorLogger>((ref) {
  return _DummyOperationErrorLogger();
});

class _DummyOperationErrorLogger implements OperationErrorLogger {
  @override
  void logError(DisplayableError error) {}
}
