// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalibrationBucket {

 double get bucketMin; double get bucketMax; int get predictedCount; double get actualWinRate;
/// Create a copy of CalibrationBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalibrationBucketCopyWith<CalibrationBucket> get copyWith => _$CalibrationBucketCopyWithImpl<CalibrationBucket>(this as CalibrationBucket, _$identity);

  /// Serializes this CalibrationBucket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalibrationBucket&&(identical(other.bucketMin, bucketMin) || other.bucketMin == bucketMin)&&(identical(other.bucketMax, bucketMax) || other.bucketMax == bucketMax)&&(identical(other.predictedCount, predictedCount) || other.predictedCount == predictedCount)&&(identical(other.actualWinRate, actualWinRate) || other.actualWinRate == actualWinRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucketMin,bucketMax,predictedCount,actualWinRate);

@override
String toString() {
  return 'CalibrationBucket(bucketMin: $bucketMin, bucketMax: $bucketMax, predictedCount: $predictedCount, actualWinRate: $actualWinRate)';
}


}

/// @nodoc
abstract mixin class $CalibrationBucketCopyWith<$Res>  {
  factory $CalibrationBucketCopyWith(CalibrationBucket value, $Res Function(CalibrationBucket) _then) = _$CalibrationBucketCopyWithImpl;
@useResult
$Res call({
 double bucketMin, double bucketMax, int predictedCount, double actualWinRate
});




}
/// @nodoc
class _$CalibrationBucketCopyWithImpl<$Res>
    implements $CalibrationBucketCopyWith<$Res> {
  _$CalibrationBucketCopyWithImpl(this._self, this._then);

  final CalibrationBucket _self;
  final $Res Function(CalibrationBucket) _then;

/// Create a copy of CalibrationBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucketMin = null,Object? bucketMax = null,Object? predictedCount = null,Object? actualWinRate = null,}) {
  return _then(_self.copyWith(
bucketMin: null == bucketMin ? _self.bucketMin : bucketMin // ignore: cast_nullable_to_non_nullable
as double,bucketMax: null == bucketMax ? _self.bucketMax : bucketMax // ignore: cast_nullable_to_non_nullable
as double,predictedCount: null == predictedCount ? _self.predictedCount : predictedCount // ignore: cast_nullable_to_non_nullable
as int,actualWinRate: null == actualWinRate ? _self.actualWinRate : actualWinRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CalibrationBucket].
extension CalibrationBucketPatterns on CalibrationBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalibrationBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalibrationBucket() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalibrationBucket value)  $default,){
final _that = this;
switch (_that) {
case _CalibrationBucket():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalibrationBucket value)?  $default,){
final _that = this;
switch (_that) {
case _CalibrationBucket() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double bucketMin,  double bucketMax,  int predictedCount,  double actualWinRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalibrationBucket() when $default != null:
return $default(_that.bucketMin,_that.bucketMax,_that.predictedCount,_that.actualWinRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double bucketMin,  double bucketMax,  int predictedCount,  double actualWinRate)  $default,) {final _that = this;
switch (_that) {
case _CalibrationBucket():
return $default(_that.bucketMin,_that.bucketMax,_that.predictedCount,_that.actualWinRate);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double bucketMin,  double bucketMax,  int predictedCount,  double actualWinRate)?  $default,) {final _that = this;
switch (_that) {
case _CalibrationBucket() when $default != null:
return $default(_that.bucketMin,_that.bucketMax,_that.predictedCount,_that.actualWinRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalibrationBucket implements CalibrationBucket {
  const _CalibrationBucket({required this.bucketMin, required this.bucketMax, required this.predictedCount, required this.actualWinRate});
  factory _CalibrationBucket.fromJson(Map<String, dynamic> json) => _$CalibrationBucketFromJson(json);

@override final  double bucketMin;
@override final  double bucketMax;
@override final  int predictedCount;
@override final  double actualWinRate;

/// Create a copy of CalibrationBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalibrationBucketCopyWith<_CalibrationBucket> get copyWith => __$CalibrationBucketCopyWithImpl<_CalibrationBucket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalibrationBucketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalibrationBucket&&(identical(other.bucketMin, bucketMin) || other.bucketMin == bucketMin)&&(identical(other.bucketMax, bucketMax) || other.bucketMax == bucketMax)&&(identical(other.predictedCount, predictedCount) || other.predictedCount == predictedCount)&&(identical(other.actualWinRate, actualWinRate) || other.actualWinRate == actualWinRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucketMin,bucketMax,predictedCount,actualWinRate);

@override
String toString() {
  return 'CalibrationBucket(bucketMin: $bucketMin, bucketMax: $bucketMax, predictedCount: $predictedCount, actualWinRate: $actualWinRate)';
}


}

/// @nodoc
abstract mixin class _$CalibrationBucketCopyWith<$Res> implements $CalibrationBucketCopyWith<$Res> {
  factory _$CalibrationBucketCopyWith(_CalibrationBucket value, $Res Function(_CalibrationBucket) _then) = __$CalibrationBucketCopyWithImpl;
@override @useResult
$Res call({
 double bucketMin, double bucketMax, int predictedCount, double actualWinRate
});




}
/// @nodoc
class __$CalibrationBucketCopyWithImpl<$Res>
    implements _$CalibrationBucketCopyWith<$Res> {
  __$CalibrationBucketCopyWithImpl(this._self, this._then);

  final _CalibrationBucket _self;
  final $Res Function(_CalibrationBucket) _then;

/// Create a copy of CalibrationBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucketMin = null,Object? bucketMax = null,Object? predictedCount = null,Object? actualWinRate = null,}) {
  return _then(_CalibrationBucket(
bucketMin: null == bucketMin ? _self.bucketMin : bucketMin // ignore: cast_nullable_to_non_nullable
as double,bucketMax: null == bucketMax ? _self.bucketMax : bucketMax // ignore: cast_nullable_to_non_nullable
as double,predictedCount: null == predictedCount ? _self.predictedCount : predictedCount // ignore: cast_nullable_to_non_nullable
as int,actualWinRate: null == actualWinRate ? _self.actualWinRate : actualWinRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PnlSummary {

 double get totalWagered; double get totalReturned; double get roi; double get winRate; int get betCount;
/// Create a copy of PnlSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PnlSummaryCopyWith<PnlSummary> get copyWith => _$PnlSummaryCopyWithImpl<PnlSummary>(this as PnlSummary, _$identity);

  /// Serializes this PnlSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PnlSummary&&(identical(other.totalWagered, totalWagered) || other.totalWagered == totalWagered)&&(identical(other.totalReturned, totalReturned) || other.totalReturned == totalReturned)&&(identical(other.roi, roi) || other.roi == roi)&&(identical(other.winRate, winRate) || other.winRate == winRate)&&(identical(other.betCount, betCount) || other.betCount == betCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalWagered,totalReturned,roi,winRate,betCount);

@override
String toString() {
  return 'PnlSummary(totalWagered: $totalWagered, totalReturned: $totalReturned, roi: $roi, winRate: $winRate, betCount: $betCount)';
}


}

/// @nodoc
abstract mixin class $PnlSummaryCopyWith<$Res>  {
  factory $PnlSummaryCopyWith(PnlSummary value, $Res Function(PnlSummary) _then) = _$PnlSummaryCopyWithImpl;
@useResult
$Res call({
 double totalWagered, double totalReturned, double roi, double winRate, int betCount
});




}
/// @nodoc
class _$PnlSummaryCopyWithImpl<$Res>
    implements $PnlSummaryCopyWith<$Res> {
  _$PnlSummaryCopyWithImpl(this._self, this._then);

  final PnlSummary _self;
  final $Res Function(PnlSummary) _then;

/// Create a copy of PnlSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalWagered = null,Object? totalReturned = null,Object? roi = null,Object? winRate = null,Object? betCount = null,}) {
  return _then(_self.copyWith(
totalWagered: null == totalWagered ? _self.totalWagered : totalWagered // ignore: cast_nullable_to_non_nullable
as double,totalReturned: null == totalReturned ? _self.totalReturned : totalReturned // ignore: cast_nullable_to_non_nullable
as double,roi: null == roi ? _self.roi : roi // ignore: cast_nullable_to_non_nullable
as double,winRate: null == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double,betCount: null == betCount ? _self.betCount : betCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PnlSummary].
extension PnlSummaryPatterns on PnlSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PnlSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PnlSummary() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PnlSummary value)  $default,){
final _that = this;
switch (_that) {
case _PnlSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PnlSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PnlSummary() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalWagered,  double totalReturned,  double roi,  double winRate,  int betCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PnlSummary() when $default != null:
return $default(_that.totalWagered,_that.totalReturned,_that.roi,_that.winRate,_that.betCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalWagered,  double totalReturned,  double roi,  double winRate,  int betCount)  $default,) {final _that = this;
switch (_that) {
case _PnlSummary():
return $default(_that.totalWagered,_that.totalReturned,_that.roi,_that.winRate,_that.betCount);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalWagered,  double totalReturned,  double roi,  double winRate,  int betCount)?  $default,) {final _that = this;
switch (_that) {
case _PnlSummary() when $default != null:
return $default(_that.totalWagered,_that.totalReturned,_that.roi,_that.winRate,_that.betCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PnlSummary implements PnlSummary {
  const _PnlSummary({required this.totalWagered, required this.totalReturned, required this.roi, required this.winRate, required this.betCount});
  factory _PnlSummary.fromJson(Map<String, dynamic> json) => _$PnlSummaryFromJson(json);

@override final  double totalWagered;
@override final  double totalReturned;
@override final  double roi;
@override final  double winRate;
@override final  int betCount;

/// Create a copy of PnlSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PnlSummaryCopyWith<_PnlSummary> get copyWith => __$PnlSummaryCopyWithImpl<_PnlSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PnlSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PnlSummary&&(identical(other.totalWagered, totalWagered) || other.totalWagered == totalWagered)&&(identical(other.totalReturned, totalReturned) || other.totalReturned == totalReturned)&&(identical(other.roi, roi) || other.roi == roi)&&(identical(other.winRate, winRate) || other.winRate == winRate)&&(identical(other.betCount, betCount) || other.betCount == betCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalWagered,totalReturned,roi,winRate,betCount);

@override
String toString() {
  return 'PnlSummary(totalWagered: $totalWagered, totalReturned: $totalReturned, roi: $roi, winRate: $winRate, betCount: $betCount)';
}


}

/// @nodoc
abstract mixin class _$PnlSummaryCopyWith<$Res> implements $PnlSummaryCopyWith<$Res> {
  factory _$PnlSummaryCopyWith(_PnlSummary value, $Res Function(_PnlSummary) _then) = __$PnlSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalWagered, double totalReturned, double roi, double winRate, int betCount
});




}
/// @nodoc
class __$PnlSummaryCopyWithImpl<$Res>
    implements _$PnlSummaryCopyWith<$Res> {
  __$PnlSummaryCopyWithImpl(this._self, this._then);

  final _PnlSummary _self;
  final $Res Function(_PnlSummary) _then;

/// Create a copy of PnlSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalWagered = null,Object? totalReturned = null,Object? roi = null,Object? winRate = null,Object? betCount = null,}) {
  return _then(_PnlSummary(
totalWagered: null == totalWagered ? _self.totalWagered : totalWagered // ignore: cast_nullable_to_non_nullable
as double,totalReturned: null == totalReturned ? _self.totalReturned : totalReturned // ignore: cast_nullable_to_non_nullable
as double,roi: null == roi ? _self.roi : roi // ignore: cast_nullable_to_non_nullable
as double,winRate: null == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double,betCount: null == betCount ? _self.betCount : betCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Streaks {

 int get currentWinStreak; int get longestWinStreak;
/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreaksCopyWith<Streaks> get copyWith => _$StreaksCopyWithImpl<Streaks>(this as Streaks, _$identity);

  /// Serializes this Streaks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Streaks&&(identical(other.currentWinStreak, currentWinStreak) || other.currentWinStreak == currentWinStreak)&&(identical(other.longestWinStreak, longestWinStreak) || other.longestWinStreak == longestWinStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentWinStreak,longestWinStreak);

@override
String toString() {
  return 'Streaks(currentWinStreak: $currentWinStreak, longestWinStreak: $longestWinStreak)';
}


}

/// @nodoc
abstract mixin class $StreaksCopyWith<$Res>  {
  factory $StreaksCopyWith(Streaks value, $Res Function(Streaks) _then) = _$StreaksCopyWithImpl;
@useResult
$Res call({
 int currentWinStreak, int longestWinStreak
});




}
/// @nodoc
class _$StreaksCopyWithImpl<$Res>
    implements $StreaksCopyWith<$Res> {
  _$StreaksCopyWithImpl(this._self, this._then);

  final Streaks _self;
  final $Res Function(Streaks) _then;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentWinStreak = null,Object? longestWinStreak = null,}) {
  return _then(_self.copyWith(
currentWinStreak: null == currentWinStreak ? _self.currentWinStreak : currentWinStreak // ignore: cast_nullable_to_non_nullable
as int,longestWinStreak: null == longestWinStreak ? _self.longestWinStreak : longestWinStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Streaks].
extension StreaksPatterns on Streaks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Streaks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Streaks value)  $default,){
final _that = this;
switch (_that) {
case _Streaks():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Streaks value)?  $default,){
final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentWinStreak,  int longestWinStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that.currentWinStreak,_that.longestWinStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentWinStreak,  int longestWinStreak)  $default,) {final _that = this;
switch (_that) {
case _Streaks():
return $default(_that.currentWinStreak,_that.longestWinStreak);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentWinStreak,  int longestWinStreak)?  $default,) {final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that.currentWinStreak,_that.longestWinStreak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Streaks implements Streaks {
  const _Streaks({required this.currentWinStreak, required this.longestWinStreak});
  factory _Streaks.fromJson(Map<String, dynamic> json) => _$StreaksFromJson(json);

@override final  int currentWinStreak;
@override final  int longestWinStreak;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreaksCopyWith<_Streaks> get copyWith => __$StreaksCopyWithImpl<_Streaks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreaksToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Streaks&&(identical(other.currentWinStreak, currentWinStreak) || other.currentWinStreak == currentWinStreak)&&(identical(other.longestWinStreak, longestWinStreak) || other.longestWinStreak == longestWinStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentWinStreak,longestWinStreak);

@override
String toString() {
  return 'Streaks(currentWinStreak: $currentWinStreak, longestWinStreak: $longestWinStreak)';
}


}

/// @nodoc
abstract mixin class _$StreaksCopyWith<$Res> implements $StreaksCopyWith<$Res> {
  factory _$StreaksCopyWith(_Streaks value, $Res Function(_Streaks) _then) = __$StreaksCopyWithImpl;
@override @useResult
$Res call({
 int currentWinStreak, int longestWinStreak
});




}
/// @nodoc
class __$StreaksCopyWithImpl<$Res>
    implements _$StreaksCopyWith<$Res> {
  __$StreaksCopyWithImpl(this._self, this._then);

  final _Streaks _self;
  final $Res Function(_Streaks) _then;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentWinStreak = null,Object? longestWinStreak = null,}) {
  return _then(_Streaks(
currentWinStreak: null == currentWinStreak ? _self.currentWinStreak : currentWinStreak // ignore: cast_nullable_to_non_nullable
as int,longestWinStreak: null == longestWinStreak ? _self.longestWinStreak : longestWinStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PerformanceData {

 List<CalibrationBucket> get calibration; PnlSummary get pnl; Streaks get streaks;
/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceDataCopyWith<PerformanceData> get copyWith => _$PerformanceDataCopyWithImpl<PerformanceData>(this as PerformanceData, _$identity);

  /// Serializes this PerformanceData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceData&&const DeepCollectionEquality().equals(other.calibration, calibration)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.streaks, streaks) || other.streaks == streaks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(calibration),pnl,streaks);

@override
String toString() {
  return 'PerformanceData(calibration: $calibration, pnl: $pnl, streaks: $streaks)';
}


}

/// @nodoc
abstract mixin class $PerformanceDataCopyWith<$Res>  {
  factory $PerformanceDataCopyWith(PerformanceData value, $Res Function(PerformanceData) _then) = _$PerformanceDataCopyWithImpl;
@useResult
$Res call({
 List<CalibrationBucket> calibration, PnlSummary pnl, Streaks streaks
});


$PnlSummaryCopyWith<$Res> get pnl;$StreaksCopyWith<$Res> get streaks;

}
/// @nodoc
class _$PerformanceDataCopyWithImpl<$Res>
    implements $PerformanceDataCopyWith<$Res> {
  _$PerformanceDataCopyWithImpl(this._self, this._then);

  final PerformanceData _self;
  final $Res Function(PerformanceData) _then;

/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calibration = null,Object? pnl = null,Object? streaks = null,}) {
  return _then(_self.copyWith(
calibration: null == calibration ? _self.calibration : calibration // ignore: cast_nullable_to_non_nullable
as List<CalibrationBucket>,pnl: null == pnl ? _self.pnl : pnl // ignore: cast_nullable_to_non_nullable
as PnlSummary,streaks: null == streaks ? _self.streaks : streaks // ignore: cast_nullable_to_non_nullable
as Streaks,
  ));
}
/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PnlSummaryCopyWith<$Res> get pnl {
  
  return $PnlSummaryCopyWith<$Res>(_self.pnl, (value) {
    return _then(_self.copyWith(pnl: value));
  });
}/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreaksCopyWith<$Res> get streaks {
  
  return $StreaksCopyWith<$Res>(_self.streaks, (value) {
    return _then(_self.copyWith(streaks: value));
  });
}
}


/// Adds pattern-matching-related methods to [PerformanceData].
extension PerformanceDataPatterns on PerformanceData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceData() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceData value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceData value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceData() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CalibrationBucket> calibration,  PnlSummary pnl,  Streaks streaks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceData() when $default != null:
return $default(_that.calibration,_that.pnl,_that.streaks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CalibrationBucket> calibration,  PnlSummary pnl,  Streaks streaks)  $default,) {final _that = this;
switch (_that) {
case _PerformanceData():
return $default(_that.calibration,_that.pnl,_that.streaks);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CalibrationBucket> calibration,  PnlSummary pnl,  Streaks streaks)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceData() when $default != null:
return $default(_that.calibration,_that.pnl,_that.streaks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceData implements PerformanceData {
  const _PerformanceData({required final  List<CalibrationBucket> calibration, required this.pnl, required this.streaks}): _calibration = calibration;
  factory _PerformanceData.fromJson(Map<String, dynamic> json) => _$PerformanceDataFromJson(json);

 final  List<CalibrationBucket> _calibration;
@override List<CalibrationBucket> get calibration {
  if (_calibration is EqualUnmodifiableListView) return _calibration;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_calibration);
}

@override final  PnlSummary pnl;
@override final  Streaks streaks;

/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceDataCopyWith<_PerformanceData> get copyWith => __$PerformanceDataCopyWithImpl<_PerformanceData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceData&&const DeepCollectionEquality().equals(other._calibration, _calibration)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.streaks, streaks) || other.streaks == streaks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_calibration),pnl,streaks);

@override
String toString() {
  return 'PerformanceData(calibration: $calibration, pnl: $pnl, streaks: $streaks)';
}


}

/// @nodoc
abstract mixin class _$PerformanceDataCopyWith<$Res> implements $PerformanceDataCopyWith<$Res> {
  factory _$PerformanceDataCopyWith(_PerformanceData value, $Res Function(_PerformanceData) _then) = __$PerformanceDataCopyWithImpl;
@override @useResult
$Res call({
 List<CalibrationBucket> calibration, PnlSummary pnl, Streaks streaks
});


@override $PnlSummaryCopyWith<$Res> get pnl;@override $StreaksCopyWith<$Res> get streaks;

}
/// @nodoc
class __$PerformanceDataCopyWithImpl<$Res>
    implements _$PerformanceDataCopyWith<$Res> {
  __$PerformanceDataCopyWithImpl(this._self, this._then);

  final _PerformanceData _self;
  final $Res Function(_PerformanceData) _then;

/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calibration = null,Object? pnl = null,Object? streaks = null,}) {
  return _then(_PerformanceData(
calibration: null == calibration ? _self._calibration : calibration // ignore: cast_nullable_to_non_nullable
as List<CalibrationBucket>,pnl: null == pnl ? _self.pnl : pnl // ignore: cast_nullable_to_non_nullable
as PnlSummary,streaks: null == streaks ? _self.streaks : streaks // ignore: cast_nullable_to_non_nullable
as Streaks,
  ));
}

/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PnlSummaryCopyWith<$Res> get pnl {
  
  return $PnlSummaryCopyWith<$Res>(_self.pnl, (value) {
    return _then(_self.copyWith(pnl: value));
  });
}/// Create a copy of PerformanceData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreaksCopyWith<$Res> get streaks {
  
  return $StreaksCopyWith<$Res>(_self.streaks, (value) {
    return _then(_self.copyWith(streaks: value));
  });
}
}

// dart format on
