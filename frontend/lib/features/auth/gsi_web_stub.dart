import 'package:flutter/widgets.dart';

/// Non-web stand-in for `google_sign_in_web`'s button API — never called
/// since [gsi_web] usage in login_screen.dart is guarded by `kIsWeb`, but the
/// real package transitively imports JS-interop code that only compiles for
/// web targets, so native builds need this instead.
enum GSIButtonTheme { filledBlack }

enum GSIButtonSize { large }

enum GSIButtonText { signinWith }

class GSIButtonConfiguration {
  const GSIButtonConfiguration({this.theme, this.size, this.text});
  final GSIButtonTheme? theme;
  final GSIButtonSize? size;
  final GSIButtonText? text;
}

Widget renderButton({GSIButtonConfiguration? configuration}) {
  throw UnsupportedError('renderButton is only available on web');
}
