import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tapped_riverpod/src/error/displayble_error.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const Result._();

  const factory Result.initial({T? data}) = ResultInitial;

  const factory Result.loading({T? data}) = ResultLoading;

  const factory Result.success(T data) = ResultSuccess;

  const factory Result.failure(DisplayableError error, {T? data}) =
      ResultFailure;

  bool get isLoading => this is ResultLoading<T>;

  bool get isSuccess => this is ResultSuccess<T>;

  bool get isInitial => this is ResultInitial<T>;

  bool get isFailure => this is ResultFailure<T>;

  bool get isDone => isSuccess || isFailure;

  ResultFailure<T>? asFailureOrNull() {
    if (isFailure) {
      return this as ResultFailure<T>;
    }
    return null;
  }

  ResultSuccess<T>? asSuccessOrNull() {
    if (isSuccess) {
      return this as ResultSuccess<T>;
    }
    return null;
  }

  /// Returns a new [Result] instance while ensuring that a fallback `previousData`
  /// is preserved if the current state does not contain data.
  ///
  /// This is especially useful when you want to maintain previously loaded
  /// data across state changes.
  ///
  /// Example:
  /// ```dart
  /// final result = Result<String>.loading();
  /// final withData = result.withFallbackData("old value");
  /// // -> Result.loading(data: "old value")
  /// ```
  Result<T> withFallbackData(T previousData) {
    return when(
      initial: (_) => Result.initial(data: previousData),
      loading: (_) => Result.loading(data: previousData),
      success: (value) => Result.success(value),
      failure: (error, _) => ResultFailure<T>(error, data: previousData),
    );
  }

  /// Returns a copy of the current [Result] with the provided `data` value.
  ///
  /// If `data` is `null`, the current instance is returned unchanged.
  /// Otherwise, a new state of the same type is created with the updated data.
  ///
  /// Example:
  /// ```dart
  /// final result = Result<String>.failure(Exception("error"), data: "old");
  /// final updated = result.copyWithData("new");
  /// // -> Result.failure(Exception("error"), data: "new")
  /// ```
  Result<T> copyWithData(T? data) {
    if (data == null) return this;

    return map(
      initial: (s) => ResultInitial(data: data),
      loading: (s) => ResultLoading(data: data),
      success: (s) => ResultSuccess(data),
      failure: (s) => ResultFailure(s.error, data: data),
    );
  }

  /// Creates a new [Result] instance of type [R] with its `data` overridden
  /// by the provided [newData].
  ///
  /// Unlike [copyWithData], this method allows changing the data type,
  /// which makes it useful when you need to transform or replace the
  /// underlying data with a different type while keeping the current state
  /// (initial, loading, success, or failure).
  ///
  /// Example:
  /// ```dart
  /// final result = Result<int>.success(42);
  /// final overridden = result.overrideData<String>("answer");
  /// // -> Result.success<String>("answer")
  /// ```
  Result<R> overrideData<R>(R newData) {
    return map(
      initial: (s) => ResultInitial(data: newData),
      loading: (s) => ResultLoading(data: newData),
      success: (s) => ResultSuccess(newData),
      failure: (s) => ResultFailure(s.error, data: newData),
    );
  }

  Result<R> mapData<R>(R Function(T data) mapper) {
    return when(
      initial: (data) =>
          Result.initial(data: data == null ? null : mapper(data)),
      loading: (data) =>
          Result.loading(data: data == null ? null : mapper(data)),
      success: (data) => Result.success(mapper(data)),
      failure: (e, data) =>
          Result.failure(e, data: data == null ? null : mapper(data)),
    );
  }

  bool get hasData => data != null;
}
