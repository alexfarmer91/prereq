import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Full-bleed brand photography behind the login/loading screens, scrimmed
/// toward [AppColors.background] so foreground content stays legible.
/// Picks the portrait or landscape crop by the viewport's own aspect ratio,
/// not by platform — a narrow desktop window gets the portrait crop too.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final portrait = size.height >= size.width;
    final asset = portrait
        ? 'assets/images/ford-gt-portrait.png'
        : 'assets/images/ford-gt-landscape.png';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid base so the (large) photo's decode time never shows through
        // as a flash of the page's blank white canvas under the scrim.
        const ColoredBox(color: AppColors.background),
        Image.asset(asset, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.55),
                AppColors.background.withValues(alpha: 0.75),
                AppColors.background,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
