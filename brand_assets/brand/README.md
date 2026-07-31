# Prereq brand assets

Master geometry lives on a **128-unit grid**: four bars (stem 14, pitch 24,
baseline y104, tops 80 / 56 / 68 / 34) with the threshold rule at y64, stem 4,
bleeding 6 units past each edge. Round caps throughout. Every file here was
generated from those numbers, so they cannot drift apart.

```
brand/
  svg/mark/      the mark, six grounds
  svg/lockup/    mark + wordmark
  svg/icon/      favicon, app icon, android adaptive foreground
  png/mark/      transparent rasters, 64–512
  png/lockup/    2× rasters with real Inter
  png/icon/      every platform icon slot
```

## Which file to use

| Context | File |
|---|---|
| Anywhere on the dark ground | `svg/mark/prereq-mark.svg` |
| 26px and below | `svg/mark/prereq-mark-compact.svg` — three bars, thicker stems |
| Light ground, print, exports | `svg/mark/prereq-mark-on-light.svg` |
| Single ink, engraving, embroidery, stamps | `…-mono-light.svg` / `…-mono-dark.svg` |
| Accent tile, stickers, avatars | `svg/mark/prereq-mark-on-accent.svg` |
| Headers, decks, README, email signature | `svg/lockup/prereq-lockup-horizontal.svg` |
| Square placements — splash, share cards | `svg/lockup/prereq-lockup-stacked.svg` |

**Clear space:** one bar-width — 14 units, ≈20% of the mark — on all four sides.
The threshold rule may bleed into it; nothing else may.

**Never** recolour the bars outside the supplied palettes, flood the accent
behind the mark other than via `-on-accent`, rotate it, add a container/badge
around it, or render the four-bar mark below 28px.

## In your Flutter repo

The app itself doesn't need any of these files — `lib/shared/widgets/prereq_mark.dart`
draws the mark with `CustomPainter` from the same grid, so it stays crisp at any
size with no asset loading. These files are for the platform icon slots and
everything outside the app.

```
brand/png/icon/favicon-32.png                     → frontend/web/favicon.png
brand/svg/icon/favicon.svg                        → frontend/web/favicon.svg
brand/png/icon/Icon-192.png                       → frontend/web/icons/Icon-192.png
brand/png/icon/Icon-512.png                       → frontend/web/icons/Icon-512.png
brand/png/icon/Icon-maskable-192.png              → frontend/web/icons/Icon-maskable-192.png
brand/png/icon/Icon-maskable-512.png              → frontend/web/icons/Icon-maskable-512.png
brand/png/icon/apple-touch-icon-180.png           → frontend/web/icons/apple-touch-icon-180.png
brand/png/icon/ios-app-store-1024.png             → ios/Runner/Assets.xcassets/AppIcon.appiconset/
brand/png/icon/android-adaptive-foreground-432.png → android/app/src/main/res/drawable/ic_launcher_foreground.png
brand/                                            → repo root (or docs/brand/) as the source of truth
```

iOS wants the full `AppIcon.appiconset` ladder and Android wants five `mipmap-*`
densities. The quickest honest path is `flutter_launcher_icons` in
`dev_dependencies`, pointed at the 1024 and the adaptive foreground:

```yaml
flutter_launcher_icons:
  image_path: "brand/png/icon/ios-app-store-1024.png"
  android: "ic_launcher"
  adaptive_icon_background: "#161826"
  adaptive_icon_foreground: "brand/png/icon/android-adaptive-foreground-432.png"
  ios: true
  web:
    generate: true
    background_color: "#161826"
    theme_color: "#161826"
```

then `dart run flutter_launcher_icons`. It writes every density from these two
files.

## One caveat on the lockup SVGs

The wordmark in `svg/lockup/*.svg` is **live text** set in Inter — it renders
correctly anywhere Inter is installed or loaded, which covers your app, your
site and any browser with the Google font. Before sending a lockup to a printer,
a conference, a partner or an app store listing, either use the PNG
(`png/lockup/*.png`, 2×, Inter baked in) or open the SVG in Illustrator/Figma and
convert the text to outlines. Say the word and I'll produce outlined SVGs so this
stops being a caveat.

## Colours

| Role | Dark ground | Light ground |
|---|---|---|
| Bar 1 (shortest) | `#75798C` | `#9397AB` |
| Bar 2 | `#B2B6CA` | `#595D6C` |
| Bar 3 | `#9397AB` | `#75798C` |
| Bar 4 (tallest) | `#E9E9ED` | `#161826` |
| Threshold rule | `#9184D9` | `#796CBF` |
| Ground | `#161826` | `#E9E9ED` |
