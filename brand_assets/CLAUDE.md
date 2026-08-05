# brand_assets — what's live vs. archived

`brand/` is the real, load-bearing brand source: `pubspec.yaml`
(`flutter_launcher_icons`) reads PNGs directly out of `brand/png/icon/`, and
`brand/svg`/`brand/png` are the canonical mark/lockup files. Treat this
directory as current.

The one-off Nocturne branding session (see commit `98c1c10`, "Re-skin app
with Nocturne design system + Prereq brand mark") also produced a
point-in-time `.dc.html` export (`Brand Sheet.dc.html`, `Prereq Logo.dc.html`,
`support.js`) plus `handoff/`/`_ds/` scratch output. All of that has since
been removed — it was reference-only, never wired into the app, and had
gone stale relative to the theme below.

The actual current source of truth for brand/theme:
- Colors, type scale, component theming: `frontend/lib/shared/theme/app_theme.dart`
- The mark itself (rendered in-app, not an asset): `frontend/lib/shared/widgets/prereq_mark.dart`
- Icon/lockup asset files: `brand_assets/brand/`
