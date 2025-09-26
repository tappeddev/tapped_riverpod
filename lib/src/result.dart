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

  bool get hasData => data != null;
}

extension ResultExtension<T> on Result<T> {
  Result<T> withPreviousData(T previousData) {
    return when(
      initial: (_) => Result.initial(data: previousData),
      loading: (_) => Result.loading(data: previousData),
      success: (value) => Result.success(value),
      failure: (error, _) => ResultFailure<T>(error, data: previousData),
    );
  }
}
