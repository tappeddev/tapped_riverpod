import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tapped_riverpod/src/error/displayble_error.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.initial({T? data}) = ResultInitial;

  const factory Result.loading({T? data}) = ResultLoading;

  const factory Result.success(T data) = ResultSuccess;

  const factory Result.failure(DisplayableError error, {T? data}) =
      ResultFailure;
}

extension ResultExtension<T> on Result<T> {
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

  bool get hasData => data != null;
}
