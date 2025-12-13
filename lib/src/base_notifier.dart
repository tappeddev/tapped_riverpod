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

  /// Whether this notifier has already been initialized.
  ///
  /// Riverpod may call [build] multiple times during the lifetime when,
  /// for example when using [Ref.watch]) changes, then [build] will be re-executed.
  ///
  /// However, certain setup logic (like creating the [CatchingExecutor] or
  /// registering one-time resources) must only run once per notifier instance.
  ///
  /// [_didBuild] ensures that:
  /// - [CatchingExecutor] is created exactly once
  /// - [onCreate] is called exactly once
  /// - while [init] may still run on every build to create the initial state
  bool _didBuild = false;

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
    if (!_didBuild) {
      _catchingExecutor = CatchingExecutor(
        errorLogger: ref.read(_errorLogger),
        type: runtimeType,
      );

      onCreate();
    }

    _didBuild = true;

    // register cleanup when provider is disposed
    ref.onDispose(() {
      _catchingExecutor.cancelAllOperations();

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
  /// - the provider is refreshed or invalidated -> todo check that...
  ///
  /// Because of this, [init] must be **idempotent** and must not contain
  /// one-time initialization logic.
  ///
  /// It is safe to use [ref.watch] and [ref.listen] here, but be aware that
  /// changes to watched providers will cause [build] and therefor also [init] to re-run.
  ///
  /// For one-time setup logic, use [onCreate] instead.
  /// See also the documentation of [Notifier.build].
  @protected
  T init();

  // document me
  @protected
  void onCreate() {}

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
  void logError(DisplayableError error, Type runtimeType, String identifier) {}
}
