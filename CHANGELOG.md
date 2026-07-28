## 4.0.4

- Fix (#51): Removed legacy `Registrar` reference on Android; plugin now uses the v2 embedding API, resolving build failure "cannot find symbol: class Registrar".
- Fix (#56): Resolved missing symbol linker errors that caused a crash on iOS 15.3; build now succeeds on iOS 13+.
- Fix (#31): Resolved `MissingPluginException` on the `launch_vpn` method channel; plugin registers correctly on both Android and iOS.
- Fix (#43): Removed `NSLog` debug statements ("Is reaching here1/2") from the iOS native layer.
- Fix (#22): Replaced the opaque `"something went wrong"` error with descriptive return values (`"App is installed but has no launch activity"`, `"App is not installed and store redirect is disabled"`).
- Fix (#36): Added Huawei AppGallery support on Android; devices with HMS but no GMS are now redirected to AppGallery (`appmarket://details?id=…`) instead of Google Play.
- Feat (#24): Added `LaunchApp.openSafari(url:)` helper to open a URL directly in Safari on iOS.
- Feat (#23): Added `LaunchApp.openUrlInBrowser()` and `LaunchApp.openUrlInChrome()` APIs to open a URL in a specific browser on Android/iOS, with automatic fallback to the system default browser if the target browser is not installed.
- Fix (#34): Added `<queries>` intent declaration in the plugin `AndroidManifest.xml` so that `isAppInstalled()` reliably detects third-party packages (e.g. Zoom) on Android 11+ without requiring apps to declare `QUERY_ALL_PACKAGES`.
- Fix (#8): `openApp()` and `openUrlInBrowser()` now catch `SecurityException` and return a descriptive message instead of crashing when called from a background context on Android 10+.
- Fix (iOS docs, #27): Documented that iOS requires a registered custom URL scheme; attempting to launch an app via bundle ID alone is not supported due to iOS sandboxing.

## 4.0.3

- Fix: ios 18 launch url issue

## 4.0.2

- Fix: Android build issue

## 4.0.1

- Updated Kotlin version to 2.0.0.

## 4.0.0

- Gradle version is updated.

## 3.1.0

- Removed QUERY_ALL_PACKAGES users permission in Android. Apps have to use queries in AndroidManifest.xml file.

## 3.0.0

- Fix for android permission QUERY_ALL_PACKAGES
- BREAKING CHANGE: Fix for returning boolean in isAppInstalled on iOS

## 2.0.2

- Added support for android v2 embedding (Thank you [Wilko Thomassen](https://github.com/WilkoThomassen))

## 2.0.1

- Updated documentation.

## 2.0.0

- Null safety version.

## 0.0.1

- Initial release.
