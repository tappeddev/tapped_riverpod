import 'dart:async';

import 'package:async/async.dart' show CancelableOperation;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Base class for custom Riverpod [Notifier]s with built-in support for
/// cancelable async operations, standardized error handling and
/// convenient helpers for loading/success/failure result states.
///
/// ## What this class provides
/// - Management of **cancelable async operations** via [CancelableOperation]
/// - A unified `runCatching` helper for:
///   - loading / success / failure state transitions
///   - automatic cancellation of previous runs
///   - centralized error logging
/// - Automatic cleanup of all running operations when the provider is disposed
///
///
/// ** 🚨🚨🚨 **
/// Even though [onDispose] is called when the provider is invalidated,
/// the *Notifier instance itself is reused* by Riverpod.
/// This means:
///
/// - Member variables **are not reset automatically**
/// - Any state stored in fields will persist across rebuilds
///
/// 👉 **Avoid keeping mutable state in member variables.**
/// If you must store state in fields, ensure it is fully cleaned up in
/// [onDispose].
abstract class BaseNotifier<T> extends Notifier<T> {
  // region public

  /// This can be overridden in:
  ///   ProviderScope(
  ///     overrides: BaseNotifier.errorLogger.overrideWithValue(myNewLogger),
  ///     ...
  ///   )
  static Provider<OperationErrorLogger> get errorLogger => _errorLogger;

  Map<String, CancelableOperation<void>> get operations => _activeOperations;

  // endregion

  final Map<String, CancelableOperation> _activeOperations = {};

  @mustCallSuper
  @override
  T build() {
    // register cleanup when provider is disposed
    ref.onDispose(() {
      cancelAllOperations();

      onDispose();
    });

    return init();
  }

  /// Initializes and returns the notifier state.
  ///
  /// Typical override:
  /// ```dart
  /// @override
  /// MyState init() => MyState(count: 0, result: InitialResult());
  /// ```
  ///
  /// This method is usually called once when the provider is first created.
  /// However, ⚠️ **Riverpod may call [build] (and therefore [init]) multiple times**
  /// during the lifetime of the notifier, for example when:
  /// - a dependency used with [Ref.watch] changes
  /// - the provider is refreshed or invalidated
  ///
  /// Because of this, [init] must be **idempotent** and must not contain
  /// one-time initialization logic.
  ///
  /// It is safe to use [ref.watch] and [ref.listen] here, but be aware that
  /// changes to watched providers will cause [build] and therefor also [init] to re-run.
  ///
  /// See also the documentation of [Notifier.build].
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
    void setStateWhenMounted(Result<R> result) {
      if (!ref.mounted) return;

      setState(result);
    }

    final errorLogger = ref.read(BaseNotifier.errorLogger);

    // cancel existing operation with same identifier
    unawaited(_activeOperations[identifier]?.cancel());

    // notify loading
    setStateWhenMounted(ResultLoading<R>());

    R? result;

    try {
      final operation = _createOperation<R>(
        call(),
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

      setStateWhenMounted(ResultSuccess<R>(callResult));
    } catch (error, stacktrace) {
      final displayableError = DisplayableError(
        exception: error,
        stackTrace: stacktrace,
      );

      errorLogger.logError(displayableError, runtimeType, identifier);

      setStateWhenMounted(ResultFailure<R>(displayableError));
    }

    return result;
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

  void cancelOperationBy({required String identifier}) {
    _activeOperations.remove(identifier)?.cancel();
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

  void onDispose() {}

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
}

final _errorLogger = Provider<OperationErrorLogger>((ref) {
  return _DummyOperationErrorLogger();
});

class _DummyOperationErrorLogger implements OperationErrorLogger {
  @override
  void logError(DisplayableError error, Type runtimeType, String identifier) {}
}
