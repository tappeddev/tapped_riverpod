import 'dart:async';
import 'package:async/async.dart' show CancelableOperation;
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:uuid/uuid.dart';

/// A standalone utility for executing async tasks with automatic
/// error capturing, cancellation support and lifecycle hooks.
///
/// Designed to replace runCatching inside Notifiers/Services without
/// depending on Riverpod or any state management.
///
/// - supports CancelableOperation
/// - provides callbacks for loading/success/error/cancel
/// - reusable in UI, Services, Repositories, Controllers
class CatchingExecutor {
  final OperationErrorLogger _errorLogger;

  final Map<String, CancelableOperation> _activeOperations = {};

  CatchingExecutor({required OperationErrorLogger errorLogger})
    : _errorLogger = errorLogger;

  Map<String, CancelableOperation<void>> get operations => _activeOperations;

  void cancelOperationBy({required String identifier}) {
    _activeOperations.remove(identifier)?.cancel();
  }

  /// Cancel and clean up **all** running operations.
  /// ⚠️ This need to handled by the creator of the instance
  Future<void> cancelAllOperations() async {
    final list = List<CancelableOperation>.from(_activeOperations.values);

    _activeOperations.clear();

    for (final op in list) {
      await op.cancel();
    }
  }

  /// Execute an async operation with catching behavior.
  ///
  /// Returns the result or `null` if failed or canceled.
  /// ⚠️ Checking for mounted in [setState] need to happen in the implementation.
  Future<R?> execute<R>({
    required String identifier,
    required Future<R> Function() task,
    required void Function(Result<R> result) setState,
    void Function()? onCancel,
  }) async {
    // cancel existing operation with same identifier
    unawaited(_activeOperations[identifier]?.cancel());

    // notify loading
    setState(ResultLoading<R>());

    R? result;

    try {
      final operation = _createOperation<R>(
        task(),
        onCancel: onCancel,
        identifier: identifier,
      );

      // We have this small extra variable, because if directly do:
      // result = await call();
      // and we force-unwrap the result (since call returns a NOT null value)
      // a null-pointer exception will be thrown in the case that the generic type is "void".
      // here is a small description: https://medium.com/flutter-community/the-curious-case-of-void-in-dart-f0535705e529
      final callResult = await operation.value;

      result = callResult;

      setState(ResultSuccess<R>(callResult));
    } catch (error, stacktrace) {
      final displayableError = DisplayableError(
        exception: error,
        stackTrace: stacktrace,
      );

      _errorLogger.logError(displayableError);

      setState(ResultFailure<R>(displayableError));
    }

    return result;
  }

  /// Create a [CancelableOperation] that will automatically canceled when [cancelAllOperations] is called.
  /// [O] represents the generic type of the operation.
  CancelableOperation<O> createOperation<O>(
    Future<O> result, {
    FutureOr<void> Function()? onCancel,
    String? overrideIdentifier,
  }) {
    final identifier = overrideIdentifier ?? const Uuid().v1();

    return _createOperation(result, identifier: identifier, onCancel: onCancel);
  }

  // region helper

  CancelableOperation<O> _createOperation<O>(
    Future<O> result, {
    required String identifier,
    FutureOr<void> Function()? onCancel,
  }) {
    final operation = CancelableOperation<O>.fromFuture(
      result,
      onCancel: () => onCancel?.call(),
    );

    operation.then(
      (_) => _activeOperations.remove(identifier),
      onCancel: () => _activeOperations.remove(identifier),
      onError: (_, _) => _activeOperations.remove(identifier),
    );

    _activeOperations[identifier] = operation;
    return operation;
  }

  // endregion
}
