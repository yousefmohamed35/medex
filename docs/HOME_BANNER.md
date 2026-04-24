# Home Banner

This project uses a reusable banner widget at:

- `lib/widgets/home_media_banner.dart`

The widget supports both **image** and **video** media types, and is called from:

- `lib/screens/student/home_screen.dart`

## Supported Media Types

Use `HomeBannerMediaType`:

- `HomeBannerMediaType.image`
- `HomeBannerMediaType.video`

## Widget Parameters

`HomeMediaBanner` accepts:

- `isAr` (`bool`): Arabic or English content toggle.
- `mediaType` (`HomeBannerMediaType`): image or video.
- `mediaPath` (`String`): asset path or network URL.
- `isAsset` (`bool`, default `true`): set `false` for network media.
- `height` (`double`, default `200`): banner height.
- `onTap` (`VoidCallback?`): optional tap action.

## Usage Examples

### 1) Image Banner (Asset)

```dart
HomeMediaBanner(
  isAr: isAr,
  mediaType: HomeBannerMediaType.image,
  mediaPath: 'assets/images/medex_hero.png',
  isAsset: true,
  onTap: () => context.go(RouteNames.store),
)
```

### 2) Video Banner (Asset)

```dart
HomeMediaBanner(
  isAr: isAr,
  mediaType: HomeBannerMediaType.video,
  mediaPath: 'assets/videos/home_banner.mp4',
  isAsset: true,
  onTap: () => context.go(RouteNames.store),
)
```

### 3) Video Banner (Network)

```dart
HomeMediaBanner(
  isAr: isAr,
  mediaType: HomeBannerMediaType.video,
  mediaPath: 'https://example.com/banner.mp4',
  isAsset: false,
)
```

## Notes

- Video playback is handled with `video_player`.
- Video mode auto-plays, loops, and is muted.
- If you use asset videos, make sure the video folder is included under Flutter assets in `pubspec.yaml`.
