// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Result<T> {

 T? get data;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>(data: $data)';
}


}

/// @nodoc
class $ResultCopyWith<T,$Res>  {
$ResultCopyWith(Result<T> _, $Res Function(Result<T>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResultInitial<T> value)?  initial,TResult Function( ResultLoading<T> value)?  loading,TResult Function( ResultSuccess<T> value)?  success,TResult Function( ResultFailure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that);case ResultLoading() when loading != null:
return loading(_that);case ResultSuccess() when success != null:
return success(_that);case ResultFailure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResultInitial<T> value)  initial,required TResult Function( ResultLoading<T> value)  loading,required TResult Function( ResultSuccess<T> value)  success,required TResult Function( ResultFailure<T> value)  failure,}){
final _that = this;
switch (_that) {
case ResultInitial():
return initial(_that);case ResultLoading():
return loading(_that);case ResultSuccess():
return success(_that);case ResultFailure():
return failure(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResultInitial<T> value)?  initial,TResult? Function( ResultLoading<T> value)?  loading,TResult? Function( ResultSuccess<T> value)?  success,TResult? Function( ResultFailure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that);case ResultLoading() when loading != null:
return loading(_that);case ResultSuccess() when success != null:
return success(_that);case ResultFailure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T? data)?  initial,TResult Function( T? data)?  loading,TResult Function( T data)?  success,TResult Function( DisplayableError error,  T? data)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that.data);case ResultLoading() when loading != null:
return loading(_that.data);case ResultSuccess() when success != null:
return success(_that.data);case ResultFailure() when failure != null:
return failure(_that.error,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T? data)  initial,required TResult Function( T? data)  loading,required TResult Function( T data)  success,required TResult Function( DisplayableError error,  T? data)  failure,}) {final _that = this;
switch (_that) {
case ResultInitial():
return initial(_that.data);case ResultLoading():
return loading(_that.data);case ResultSuccess():
return success(_that.data);case ResultFailure():
return failure(_that.error,_that.data);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T? data)?  initial,TResult? Function( T? data)?  loading,TResult? Function( T data)?  success,TResult? Function( DisplayableError error,  T? data)?  failure,}) {final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that.data);case ResultLoading() when loading != null:
return loading(_that.data);case ResultSuccess() when success != null:
return success(_that.data);case ResultFailure() when failure != null:
return failure(_that.error,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class ResultInitial<T> extends Result<T> {
  const ResultInitial({this.data}): super._();
  

@override final  T? data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultInitialCopyWith<T, ResultInitial<T>> get copyWith => _$ResultInitialCopyWithImpl<T, ResultInitial<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultInitial<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>.initial(data: $data)';
}


}

/// @nodoc
abstract mixin class $ResultInitialCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultInitialCopyWith(ResultInitial<T> value, $Res Function(ResultInitial<T>) _then) = _$ResultInitialCopyWithImpl;
@useResult
$Res call({
 T? data
});




}
/// @nodoc
class _$ResultInitialCopyWithImpl<T,$Res>
    implements $ResultInitialCopyWith<T, $Res> {
  _$ResultInitialCopyWithImpl(this._self, this._then);

  final ResultInitial<T> _self;
  final $Res Function(ResultInitial<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(ResultInitial<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class ResultLoading<T> extends Result<T> {
  const ResultLoading({this.data}): super._();
  

@override final  T? data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultLoadingCopyWith<T, ResultLoading<T>> get copyWith => _$ResultLoadingCopyWithImpl<T, ResultLoading<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultLoading<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>.loading(data: $data)';
}


}

/// @nodoc
abstract mixin class $ResultLoadingCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultLoadingCopyWith(ResultLoading<T> value, $Res Function(ResultLoading<T>) _then) = _$ResultLoadingCopyWithImpl;
@useResult
$Res call({
 T? data
});




}
/// @nodoc
class _$ResultLoadingCopyWithImpl<T,$Res>
    implements $ResultLoadingCopyWith<T, $Res> {
  _$ResultLoadingCopyWithImpl(this._self, this._then);

  final ResultLoading<T> _self;
  final $Res Function(ResultLoading<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(ResultLoading<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data): super._();
  

@override final  T data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultSuccessCopyWith<T, ResultSuccess<T>> get copyWith => _$ResultSuccessCopyWithImpl<T, ResultSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultSuccess<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $ResultSuccessCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultSuccessCopyWith(ResultSuccess<T> value, $Res Function(ResultSuccess<T>) _then) = _$ResultSuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$ResultSuccessCopyWithImpl<T,$Res>
    implements $ResultSuccessCopyWith<T, $Res> {
  _$ResultSuccessCopyWithImpl(this._self, this._then);

  final ResultSuccess<T> _self;
  final $Res Function(ResultSuccess<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(ResultSuccess<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.error, {this.data}): super._();
  

 final  DisplayableError error;
@override final  T? data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultFailureCopyWith<T, ResultFailure<T>> get copyWith => _$ResultFailureCopyWithImpl<T, ResultFailure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultFailure<T>&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,error,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>.failure(error: $error, data: $data)';
}


}

/// @nodoc
abstract mixin class $ResultFailureCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultFailureCopyWith(ResultFailure<T> value, $Res Function(ResultFailure<T>) _then) = _$ResultFailureCopyWithImpl;
@useResult
$Res call({
 DisplayableError error, T? data
});




}
/// @nodoc
class _$ResultFailureCopyWithImpl<T,$Res>
    implements $ResultFailureCopyWith<T, $Res> {
  _$ResultFailureCopyWithImpl(this._self, this._then);

  final ResultFailure<T> _self;
  final $Res Function(ResultFailure<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? data = freezed,}) {
  return _then(ResultFailure<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DisplayableError,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

// dart format on
