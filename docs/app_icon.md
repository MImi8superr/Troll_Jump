# App icon

Put the final launcher icon PNG here:

```text
assets/icons/app_icon.png
```

Recommended source image:

- PNG format
- Square image
- At least `1024 x 1024` pixels
- No rounded corners; Android and iOS apply their own masks

After adding or replacing `assets/icons/app_icon.png`, run these commands from the project root:

```bash
flutter pub get
dart run flutter_launcher_icons
```

The generator will update the native launcher icon files for Android, iOS, web, Windows, and macOS using the configuration in `pubspec.yaml`.

## Why App Store Connect may still show the Flutter icon

Only adding `assets/icons/app_icon.png` to GitHub is not enough for an iOS App Store build. The PNG must be converted into the native iOS asset catalog before the IPA is built:

```text
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

The GitHub Actions iOS build now runs `dart run flutter_launcher_icons` after `flutter pub get` and before `flutter build ipa`, so future uploaded IPAs should include the generated iOS app icons automatically.

If App Store Connect still shows an old build with the Flutter placeholder:

1. Make sure `assets/icons/app_icon.png` exists on the branch that triggers `.github/workflows/build-ios.yml`.
2. Re-run the iOS build workflow or push a new commit to `main`.
3. Upload/use the new build number in App Store Connect.
4. Wait for Apple processing to finish; old processed builds will keep the icon they were built with.
