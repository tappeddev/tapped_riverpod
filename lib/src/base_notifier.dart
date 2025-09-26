import 'dart:async';

import 'package:async/async.dart' show CancelableOperation;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tapped_riverpod/src/error/displayble_error.dart';
import 'package:tapped_riverpod/src/result.dart';
import 'package:uuid/uuid.dart';

/// Base class for custom Notifiers that provides:
/// - cancelable async operations
/// - standardized error handling
/// - helper for loading/success/failure Result states
abstract class BaseNotifier<T> extends Notifier<T> {
  final _activeOperations = <String, CancelableOperation<void>>{};

  @visibleForTesting
  Map<String, CancelableOperation<void>> get operations => _activeOperations;

  @mustCallSuper
  @override
  T build() {
    // register cleanup when provider is disposed
    ref.onDispose(() {
      final operations = List.of(_activeOperations.values);

      for (final element in operations) {
        element.cancel();
      }

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
    // cancel existing operation with same identifier
    unawaited(_activeOperations[identifier]?.cancel());

    // notify loading
    setState(ResultLoading<R>());

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

      setState(ResultSuccess<R>(callResult));
    } catch (error, stacktrace) {
      final displayableError = DisplayableError(
        exception: error,
        stackTrace: stacktrace,
      );

      setState(ResultFailure<R>(displayableError));
    }

    return result;
  }

  void cancelRunCatchingBy({required String identifier}) {
    _activeOperations.remove(identifier)?.cancel();
  }

  /// Create a [CancelableOperation] that will automatically canceled when [dispose] is called.
  /// [O] represents the generic type of the operation.
  @protected
  CancelableOperation<O> createOperation<O>(
    Future<O> result, {
    FutureOr<void> Function()? onCancel,
    String? overrideIdentifier,
  }) {
    final identifier = overrideIdentifier ?? const Uuid().v1();

    return _createOperation(result, identifier: identifier, onCancel: onCancel);
  }

  void onDispose() {}

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
