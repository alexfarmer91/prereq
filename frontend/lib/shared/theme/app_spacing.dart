import 'package:flutter/widgets.dart';

/// Nocturne's spacing scale — density 0.70×, already baked in. Use these
/// instead of raw numbers so the app stays dense on purpose rather than by
/// accident.
///
/// `Padding(padding: EdgeInsets.all(AppSpace.s4))`
abstract final class AppSpace {
  /// 2.8 — hairline gaps: label to value.
  static const double s1 = 2.8;

  /// 5.6 — icon to text.
  static const double s2 = 5.6;

  /// 8.4 — inside chips and tight rows.
  static const double s3 = 8.4;

  /// 11.2 — card padding, field padding.
  static const double s4 = 11.2;

  /// 16.8 — between cards, screen gutters on mobile.
  static const double s6 = 16.8;

  /// 22.4 — section separation, screen gutters on wide layouts.
  static const double s8 = 22.4;

  static const EdgeInsets card = EdgeInsets.all(s4);
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: s6);
  static const EdgeInsets screenWide = EdgeInsets.symmetric(horizontal: s8);

  static const SizedBox gap1 = SizedBox(height: s1, width: s1);
  static const SizedBox gap2 = SizedBox(height: s2, width: s2);
  static const SizedBox gap3 = SizedBox(height: s3, width: s3);
  static const SizedBox gap4 = SizedBox(height: s4, width: s4);
  static const SizedBox gap6 = SizedBox(height: s6, width: s6);
  static const SizedBox gap8 = SizedBox(height: s8, width: s8);
}
