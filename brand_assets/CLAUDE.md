# brand_assets — what's live vs. archived

`brand/` is the real, load-bearing brand source: `pubspec.yaml`
(`flutter_launcher_icons`) reads PNGs directly out of `brand/png/icon/`, and
`brand/svg`/`brand/png` are the canonical mark/lockup files. Treat this
directory as current.

`Brand Sheet.dc.html`, `Prereq Logo.dc.html`, and `support.js` are **static,
point-in-time exports** generated during the one-off Nocturne branding
session (see commit `98c1c10`, "Re-skin app with Nocturne design system +
Prereq brand mark"). They are not regenerated automatically and will not
reflect any later change to the brand or theme. Do not read them as the
current design direction, and do not treat "update these files" as part of
any future rebrand/theme work unless explicitly asked — they're an archived
snapshot, not a live document.

The actual current source of truth for brand/theme:
- Colors, type scale, component theming: `frontend/lib/shared/theme/app_theme.dart`
- The mark itself (rendered in-app, not an asset): `frontend/lib/shared/widgets/prereq_mark.dart`
- Icon/lockup asset files: `brand_assets/brand/`

`handoff/` and `_ds/` are scratch output from that same one-off session
(handoff copies already merged into `frontend/lib`/`frontend/web`; `_ds/` is
design-tool bundle metadata) — ignore both for the same reason.
