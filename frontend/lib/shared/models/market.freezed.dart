// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Score {

 double get fairProbability; ScoreConfidence get confidence; double get edge; double get evPerDollar; String get rationale; List<String> get signals; List<String> get risks; DateTime get scoredAt;
/// Create a copy of Score
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScoreCopyWith<Score> get copyWith => _$ScoreCopyWithImpl<Score>(this as Score, _$identity);

  /// Serializes this Score to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Score&&(identical(other.fairProbability, fairProbability) || other.fairProbability == fairProbability)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.edge, edge) || other.edge == edge)&&(identical(other.evPerDollar, evPerDollar) || other.evPerDollar == evPerDollar)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other.signals, signals)&&const DeepCollectionEquality().equals(other.risks, risks)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fairProbability,confidence,edge,evPerDollar,rationale,const DeepCollectionEquality().hash(signals),const DeepCollectionEquality().hash(risks),scoredAt);

@override
String toString() {
  return 'Score(fairProbability: $fairProbability, confidence: $confidence, edge: $edge, evPerDollar: $evPerDollar, rationale: $rationale, signals: $signals, risks: $risks, scoredAt: $scoredAt)';
}


}

/// @nodoc
abstract mixin class $ScoreCopyWith<$Res>  {
  factory $ScoreCopyWith(Score value, $Res Function(Score) _then) = _$ScoreCopyWithImpl;
@useResult
$Res call({
 double fairProbability, ScoreConfidence confidence, double edge, double evPerDollar, String rationale, List<String> signals, List<String> risks, DateTime scoredAt
});




}
/// @nodoc
class _$ScoreCopyWithImpl<$Res>
    implements $ScoreCopyWith<$Res> {
  _$ScoreCopyWithImpl(this._self, this._then);

  final Score _self;
  final $Res Function(Score) _then;

/// Create a copy of Score
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fairProbability = null,Object? confidence = null,Object? edge = null,Object? evPerDollar = null,Object? rationale = null,Object? signals = null,Object? risks = null,Object? scoredAt = null,}) {
  return _then(_self.copyWith(
fairProbability: null == fairProbability ? _self.fairProbability : fairProbability // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ScoreConfidence,edge: null == edge ? _self.edge : edge // ignore: cast_nullable_to_non_nullable
as double,evPerDollar: null == evPerDollar ? _self.evPerDollar : evPerDollar // ignore: cast_nullable_to_non_nullable
as double,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self.signals : signals // ignore: cast_nullable_to_non_nullable
as List<String>,risks: null == risks ? _self.risks : risks // ignore: cast_nullable_to_non_nullable
as List<String>,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Score].
extension ScorePatterns on Score {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Score value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Score() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Score value)  $default,){
final _that = this;
switch (_that) {
case _Score():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Score value)?  $default,){
final _that = this;
switch (_that) {
case _Score() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fairProbability,  ScoreConfidence confidence,  double edge,  double evPerDollar,  String rationale,  List<String> signals,  List<String> risks,  DateTime scoredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Score() when $default != null:
return $default(_that.fairProbability,_that.confidence,_that.edge,_that.evPerDollar,_that.rationale,_that.signals,_that.risks,_that.scoredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fairProbability,  ScoreConfidence confidence,  double edge,  double evPerDollar,  String rationale,  List<String> signals,  List<String> risks,  DateTime scoredAt)  $default,) {final _that = this;
switch (_that) {
case _Score():
return $default(_that.fairProbability,_that.confidence,_that.edge,_that.evPerDollar,_that.rationale,_that.signals,_that.risks,_that.scoredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fairProbability,  ScoreConfidence confidence,  double edge,  double evPerDollar,  String rationale,  List<String> signals,  List<String> risks,  DateTime scoredAt)?  $default,) {final _that = this;
switch (_that) {
case _Score() when $default != null:
return $default(_that.fairProbability,_that.confidence,_that.edge,_that.evPerDollar,_that.rationale,_that.signals,_that.risks,_that.scoredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Score implements Score {
  const _Score({required this.fairProbability, required this.confidence, required this.edge, required this.evPerDollar, required this.rationale, required final  List<String> signals, required final  List<String> risks, required this.scoredAt}): _signals = signals,_risks = risks;
  factory _Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

@override final  double fairProbability;
@override final  ScoreConfidence confidence;
@override final  double edge;
@override final  double evPerDollar;
@override final  String rationale;
 final  List<String> _signals;
@override List<String> get signals {
  if (_signals is EqualUnmodifiableListView) return _signals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signals);
}

 final  List<String> _risks;
@override List<String> get risks {
  if (_risks is EqualUnmodifiableListView) return _risks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_risks);
}

@override final  DateTime scoredAt;

/// Create a copy of Score
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScoreCopyWith<_Score> get copyWith => __$ScoreCopyWithImpl<_Score>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Score&&(identical(other.fairProbability, fairProbability) || other.fairProbability == fairProbability)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.edge, edge) || other.edge == edge)&&(identical(other.evPerDollar, evPerDollar) || other.evPerDollar == evPerDollar)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other._signals, _signals)&&const DeepCollectionEquality().equals(other._risks, _risks)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fairProbability,confidence,edge,evPerDollar,rationale,const DeepCollectionEquality().hash(_signals),const DeepCollectionEquality().hash(_risks),scoredAt);

@override
String toString() {
  return 'Score(fairProbability: $fairProbability, confidence: $confidence, edge: $edge, evPerDollar: $evPerDollar, rationale: $rationale, signals: $signals, risks: $risks, scoredAt: $scoredAt)';
}


}

/// @nodoc
abstract mixin class _$ScoreCopyWith<$Res> implements $ScoreCopyWith<$Res> {
  factory _$ScoreCopyWith(_Score value, $Res Function(_Score) _then) = __$ScoreCopyWithImpl;
@override @useResult
$Res call({
 double fairProbability, ScoreConfidence confidence, double edge, double evPerDollar, String rationale, List<String> signals, List<String> risks, DateTime scoredAt
});




}
/// @nodoc
class __$ScoreCopyWithImpl<$Res>
    implements _$ScoreCopyWith<$Res> {
  __$ScoreCopyWithImpl(this._self, this._then);

  final _Score _self;
  final $Res Function(_Score) _then;

/// Create a copy of Score
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fairProbability = null,Object? confidence = null,Object? edge = null,Object? evPerDollar = null,Object? rationale = null,Object? signals = null,Object? risks = null,Object? scoredAt = null,}) {
  return _then(_Score(
fairProbability: null == fairProbability ? _self.fairProbability : fairProbability // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ScoreConfidence,edge: null == edge ? _self.edge : edge // ignore: cast_nullable_to_non_nullable
as double,evPerDollar: null == evPerDollar ? _self.evPerDollar : evPerDollar // ignore: cast_nullable_to_non_nullable
as double,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self._signals : signals // ignore: cast_nullable_to_non_nullable
as List<String>,risks: null == risks ? _self._risks : risks // ignore: cast_nullable_to_non_nullable
as List<String>,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Market {

 String get ticker; String get eventTicker; String get title; double get yesBid; double get yesAsk; double get noBid; double get noAsk; double get midPrice; double get spread;@JsonKey(name: 'volume_24h') double get volume24h; DateTime get closeTime; String? get rulesPrimary; String get category; Score? get score;
/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketCopyWith<Market> get copyWith => _$MarketCopyWithImpl<Market>(this as Market, _$identity);

  /// Serializes this Market to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Market&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.eventTicker, eventTicker) || other.eventTicker == eventTicker)&&(identical(other.title, title) || other.title == title)&&(identical(other.yesBid, yesBid) || other.yesBid == yesBid)&&(identical(other.yesAsk, yesAsk) || other.yesAsk == yesAsk)&&(identical(other.noBid, noBid) || other.noBid == noBid)&&(identical(other.noAsk, noAsk) || other.noAsk == noAsk)&&(identical(other.midPrice, midPrice) || other.midPrice == midPrice)&&(identical(other.spread, spread) || other.spread == spread)&&(identical(other.volume24h, volume24h) || other.volume24h == volume24h)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rulesPrimary, rulesPrimary) || other.rulesPrimary == rulesPrimary)&&(identical(other.category, category) || other.category == category)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticker,eventTicker,title,yesBid,yesAsk,noBid,noAsk,midPrice,spread,volume24h,closeTime,rulesPrimary,category,score);

@override
String toString() {
  return 'Market(ticker: $ticker, eventTicker: $eventTicker, title: $title, yesBid: $yesBid, yesAsk: $yesAsk, noBid: $noBid, noAsk: $noAsk, midPrice: $midPrice, spread: $spread, volume24h: $volume24h, closeTime: $closeTime, rulesPrimary: $rulesPrimary, category: $category, score: $score)';
}


}

/// @nodoc
abstract mixin class $MarketCopyWith<$Res>  {
  factory $MarketCopyWith(Market value, $Res Function(Market) _then) = _$MarketCopyWithImpl;
@useResult
$Res call({
 String ticker, String eventTicker, String title, double yesBid, double yesAsk, double noBid, double noAsk, double midPrice, double spread,@JsonKey(name: 'volume_24h') double volume24h, DateTime closeTime, String? rulesPrimary, String category, Score? score
});


$ScoreCopyWith<$Res>? get score;

}
/// @nodoc
class _$MarketCopyWithImpl<$Res>
    implements $MarketCopyWith<$Res> {
  _$MarketCopyWithImpl(this._self, this._then);

  final Market _self;
  final $Res Function(Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticker = null,Object? eventTicker = null,Object? title = null,Object? yesBid = null,Object? yesAsk = null,Object? noBid = null,Object? noAsk = null,Object? midPrice = null,Object? spread = null,Object? volume24h = null,Object? closeTime = null,Object? rulesPrimary = freezed,Object? category = null,Object? score = freezed,}) {
  return _then(_self.copyWith(
ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,eventTicker: null == eventTicker ? _self.eventTicker : eventTicker // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,yesBid: null == yesBid ? _self.yesBid : yesBid // ignore: cast_nullable_to_non_nullable
as double,yesAsk: null == yesAsk ? _self.yesAsk : yesAsk // ignore: cast_nullable_to_non_nullable
as double,noBid: null == noBid ? _self.noBid : noBid // ignore: cast_nullable_to_non_nullable
as double,noAsk: null == noAsk ? _self.noAsk : noAsk // ignore: cast_nullable_to_non_nullable
as double,midPrice: null == midPrice ? _self.midPrice : midPrice // ignore: cast_nullable_to_non_nullable
as double,spread: null == spread ? _self.spread : spread // ignore: cast_nullable_to_non_nullable
as double,volume24h: null == volume24h ? _self.volume24h : volume24h // ignore: cast_nullable_to_non_nullable
as double,closeTime: null == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as DateTime,rulesPrimary: freezed == rulesPrimary ? _self.rulesPrimary : rulesPrimary // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as Score?,
  ));
}
/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScoreCopyWith<$Res>? get score {
    if (_self.score == null) {
    return null;
  }

  return $ScoreCopyWith<$Res>(_self.score!, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}


/// Adds pattern-matching-related methods to [Market].
extension MarketPatterns on Market {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Market value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Market value)  $default,){
final _that = this;
switch (_that) {
case _Market():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Market value)?  $default,){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ticker,  String eventTicker,  String title,  double yesBid,  double yesAsk,  double noBid,  double noAsk,  double midPrice,  double spread, @JsonKey(name: 'volume_24h')  double volume24h,  DateTime closeTime,  String? rulesPrimary,  String category,  Score? score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.ticker,_that.eventTicker,_that.title,_that.yesBid,_that.yesAsk,_that.noBid,_that.noAsk,_that.midPrice,_that.spread,_that.volume24h,_that.closeTime,_that.rulesPrimary,_that.category,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ticker,  String eventTicker,  String title,  double yesBid,  double yesAsk,  double noBid,  double noAsk,  double midPrice,  double spread, @JsonKey(name: 'volume_24h')  double volume24h,  DateTime closeTime,  String? rulesPrimary,  String category,  Score? score)  $default,) {final _that = this;
switch (_that) {
case _Market():
return $default(_that.ticker,_that.eventTicker,_that.title,_that.yesBid,_that.yesAsk,_that.noBid,_that.noAsk,_that.midPrice,_that.spread,_that.volume24h,_that.closeTime,_that.rulesPrimary,_that.category,_that.score);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ticker,  String eventTicker,  String title,  double yesBid,  double yesAsk,  double noBid,  double noAsk,  double midPrice,  double spread, @JsonKey(name: 'volume_24h')  double volume24h,  DateTime closeTime,  String? rulesPrimary,  String category,  Score? score)?  $default,) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.ticker,_that.eventTicker,_that.title,_that.yesBid,_that.yesAsk,_that.noBid,_that.noAsk,_that.midPrice,_that.spread,_that.volume24h,_that.closeTime,_that.rulesPrimary,_that.category,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Market extends Market {
  const _Market({required this.ticker, required this.eventTicker, required this.title, required this.yesBid, required this.yesAsk, required this.noBid, required this.noAsk, required this.midPrice, required this.spread, @JsonKey(name: 'volume_24h') required this.volume24h, required this.closeTime, this.rulesPrimary, required this.category, this.score}): super._();
  factory _Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);

@override final  String ticker;
@override final  String eventTicker;
@override final  String title;
@override final  double yesBid;
@override final  double yesAsk;
@override final  double noBid;
@override final  double noAsk;
@override final  double midPrice;
@override final  double spread;
@override@JsonKey(name: 'volume_24h') final  double volume24h;
@override final  DateTime closeTime;
@override final  String? rulesPrimary;
@override final  String category;
@override final  Score? score;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketCopyWith<_Market> get copyWith => __$MarketCopyWithImpl<_Market>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Market&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.eventTicker, eventTicker) || other.eventTicker == eventTicker)&&(identical(other.title, title) || other.title == title)&&(identical(other.yesBid, yesBid) || other.yesBid == yesBid)&&(identical(other.yesAsk, yesAsk) || other.yesAsk == yesAsk)&&(identical(other.noBid, noBid) || other.noBid == noBid)&&(identical(other.noAsk, noAsk) || other.noAsk == noAsk)&&(identical(other.midPrice, midPrice) || other.midPrice == midPrice)&&(identical(other.spread, spread) || other.spread == spread)&&(identical(other.volume24h, volume24h) || other.volume24h == volume24h)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rulesPrimary, rulesPrimary) || other.rulesPrimary == rulesPrimary)&&(identical(other.category, category) || other.category == category)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticker,eventTicker,title,yesBid,yesAsk,noBid,noAsk,midPrice,spread,volume24h,closeTime,rulesPrimary,category,score);

@override
String toString() {
  return 'Market(ticker: $ticker, eventTicker: $eventTicker, title: $title, yesBid: $yesBid, yesAsk: $yesAsk, noBid: $noBid, noAsk: $noAsk, midPrice: $midPrice, spread: $spread, volume24h: $volume24h, closeTime: $closeTime, rulesPrimary: $rulesPrimary, category: $category, score: $score)';
}


}

/// @nodoc
abstract mixin class _$MarketCopyWith<$Res> implements $MarketCopyWith<$Res> {
  factory _$MarketCopyWith(_Market value, $Res Function(_Market) _then) = __$MarketCopyWithImpl;
@override @useResult
$Res call({
 String ticker, String eventTicker, String title, double yesBid, double yesAsk, double noBid, double noAsk, double midPrice, double spread,@JsonKey(name: 'volume_24h') double volume24h, DateTime closeTime, String? rulesPrimary, String category, Score? score
});


@override $ScoreCopyWith<$Res>? get score;

}
/// @nodoc
class __$MarketCopyWithImpl<$Res>
    implements _$MarketCopyWith<$Res> {
  __$MarketCopyWithImpl(this._self, this._then);

  final _Market _self;
  final $Res Function(_Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticker = null,Object? eventTicker = null,Object? title = null,Object? yesBid = null,Object? yesAsk = null,Object? noBid = null,Object? noAsk = null,Object? midPrice = null,Object? spread = null,Object? volume24h = null,Object? closeTime = null,Object? rulesPrimary = freezed,Object? category = null,Object? score = freezed,}) {
  return _then(_Market(
ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,eventTicker: null == eventTicker ? _self.eventTicker : eventTicker // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,yesBid: null == yesBid ? _self.yesBid : yesBid // ignore: cast_nullable_to_non_nullable
as double,yesAsk: null == yesAsk ? _self.yesAsk : yesAsk // ignore: cast_nullable_to_non_nullable
as double,noBid: null == noBid ? _self.noBid : noBid // ignore: cast_nullable_to_non_nullable
as double,noAsk: null == noAsk ? _self.noAsk : noAsk // ignore: cast_nullable_to_non_nullable
as double,midPrice: null == midPrice ? _self.midPrice : midPrice // ignore: cast_nullable_to_non_nullable
as double,spread: null == spread ? _self.spread : spread // ignore: cast_nullable_to_non_nullable
as double,volume24h: null == volume24h ? _self.volume24h : volume24h // ignore: cast_nullable_to_non_nullable
as double,closeTime: null == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as DateTime,rulesPrimary: freezed == rulesPrimary ? _self.rulesPrimary : rulesPrimary // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as Score?,
  ));
}

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScoreCopyWith<$Res>? get score {
    if (_self.score == null) {
    return null;
  }

  return $ScoreCopyWith<$Res>(_self.score!, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}

// dart format on
