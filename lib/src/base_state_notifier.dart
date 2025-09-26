import 'dart:async';

import 'package:async/async.dart' show CancelableOperation;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/legacy.dart';
import 'package:tapped_riverpod/src/error/displayble_error.dart';
import 'package:tapped_riverpod/src/result.dart';
import 'package:uuid/uuid.dart';

/// This provider adds default functionality to our [StateProvider] and
/// can be used for repetitive task such as loading a async resource with
/// correct error handling.
abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  final _activeOperations = <String, CancelableOperation<void>>{};

  @visibleForTesting
  Map<String, CancelableOperation<void>> get operations => _activeOperations;

  BaseStateNotifier(super.state);

  /// Runs the code in [call].
  /// This method returns null if the operation failed.
  @protected
  @visibleForTesting
  Future<R?> runCatching<R>(
    Future<R> Function() call, {
    required String identifier,
    required void Function(Result<R> result) setState,
    R? Function()? getLoadingData,
    void Function()? onCancel,
  }) async {
    unawaited(_activeOperations[identifier]?.cancel());

    void saveSetState(Result<R> result) {
      if (!mounted) {
        return;
      }

      setState(result);
    }

    saveSetState(ResultLoading<R>(data: getLoadingData?.call()));

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

      saveSetState(ResultSuccess<R>(callResult));
    } catch (error, stacktrace) {
      final displayableError = DisplayableError(
        exception: error,
        stackTrace: stacktrace,
      );

      saveSetState(ResultFailure<R>(displayableError));
    }

    if (!mounted) {
      // a never completing future since nobody calls complete()
      return Completer<R?>().future;
    }

    return result;
  }

  void cancelRunCatchingBy({required String identifier}) {
    _activeOperations[identifier]?.cancel();
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

  @override
  void dispose() {
    final operations = List.of(_activeOperations.values);

    for (final element in operations) {
      element.cancel();
    }

    super.dispose();
  }

  // region helper

  CancelableOperation<O> _createOperation<O>(
    Future<O> result, {
    required FutureOr<void> Function()? onCancel,
    required String identifier,
  }) {
    final operation = CancelableOperation<O>.fromFuture(
      result,
      onCancel: () {
        onCancel?.call();
      },
    );

    operation.then(
      (p0) => _activeOperations.remove(identifier),
      onCancel: () => _activeOperations.remove(identifier),
      onError: (_, _) => _activeOperations.remove(identifier),
    );

    _activeOperations[identifier] = operation;

    return operation;
  }

  // endregion
}
