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
