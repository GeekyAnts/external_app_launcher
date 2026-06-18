## Overview

A Flutter plugin to open another app from your app, with optional store redirect when the target app is not installed.

## Installation

Add the package via [pub.dev](https://pub.dev/packages/external_app_launcher/install).

---

## Platform setup

### Android

Add a `<queries>` block **above the `<application>` tag** in `android/app/src/main/AndroidManifest.xml` for each package you intend to check or launch. This is required on Android 11+ — without it the system hides other packages and every call will behave as if the app is not installed.

```xml
<queries>
    <package android:name="com.target.app" />
</queries>
```

If you use `androidIntentUri`, also declare the intent scheme your URI uses:

```xml
<queries>
    <package android:name="com.target.app" />
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

### iOS

Add the URL scheme of each app you want to query under `LSApplicationQueriesSchemes` in `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>pulsesecure</string>
</array>
```

Only the **scheme** needs to be listed (e.g. `pulsesecure`), not the full URL. `iosUrlScheme` may include a path and query string for deep links (e.g. `myapp://path?code=123`).

---

## Usage

### `LaunchApp.openApp`

Opens the target app. If the app is not installed, redirects to the Play Store / App Store when `openStore` is not `false`.

| Parameter | Platform | Description |
|-----------|----------|-------------|
| `androidPackageName` | Android | Application id (e.g. `com.instagram.android`) |
| `iosUrlScheme` | iOS | URL scheme or full deep-link URL (e.g. `instagram://`) |
| `appStoreLink` | Both | Store URL to open when the app is missing |
| `openStore` | Both | Set `false` to suppress the store redirect |
| `androidIntentUri` | Android | Full [intent-scheme URI](https://developer.android.com/reference/android/content/Intent#intent-scheme) for passing data to the target app |

Returns `1` when the app was opened, `0` otherwise.

**Basic usage:**

```dart
await LaunchApp.openApp(
  androidPackageName: 'net.pulsesecure.pulsesecure',
  iosUrlScheme: 'pulsesecure://',
  appStoreLink: 'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
  // openStore: false
);
```

**With intent URI (Android) — for passing data to the target app:**

```dart
await LaunchApp.openApp(
  androidIntentUri:
      'intent://payment#Intent;scheme=twint;S.code=T23LU9K;S.startingOrigin=EXTERNAL_WEB_BROWSER;end',
  androidPackageName: 'ch.twint.payment', // optional; used for Play Store fallback
  iosUrlScheme: 'twint://',
);
```

### `LaunchApp.isAppInstalled`

Returns `true` if the app is installed (Android) or its URL scheme is registered (iOS).

```dart
await LaunchApp.isAppInstalled(
  androidPackageName: 'net.pulsesecure.pulsesecure',
  iosUrlScheme: 'pulsesecure://',
);
```

On Android, you can also pass `androidIntentUri` to check whether any activity on the device resolves that intent:

```dart
await LaunchApp.isAppInstalled(
  androidIntentUri: 'intent://payment#Intent;scheme=twint;S.code=abc;end',
);
```

> **Note:** on iOS, `isAppInstalled` uses `canOpenURL` — it checks whether the scheme is registered, not whether a specific application is installed.

---

## Demo

**Android**

<img src="https://user-images.githubusercontent.com/60135944/171337872-81b89d2c-2c8b-4ecf-9702-33788821124c.gif" width="400"/>

**iOS**

<img src="https://user-images.githubusercontent.com/60135944/171337798-bdf3f78d-d002-4353-aab3-8b07dd688916.gif" width="400"/>

---

## Full example

```dart
import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 1. Basic launch — opens Instagram if installed, otherwise redirects
              //    to the store. Returns 1 when the app opened, 0 otherwise.
              //    Add the package to <queries> in AndroidManifest.xml (Android 11+).
              ElevatedButton(
                onPressed: () async {
                  final result = await LaunchApp.openApp(
                    androidPackageName: 'com.instagram.android',
                    iosUrlScheme: 'instagram://',
                    // When the app is not installed:
                    //   Android → Play Store (pass openStore: false to suppress)
                    //   iOS     → App Store via appStoreLink (no redirect without it)
                    appStoreLink:
                        'itms-apps://itunes.apple.com/app/instagram/id389801252',
                    // openStore: false  // uncomment to disable store redirect
                  );
                  debugPrint('openApp result: $result');
                },
                child: const Text('Open Instagram'),
              ),

              // 2. Check install state before deciding whether to prompt the user.
              //    On iOS this follows canOpenURL rules — it checks if the scheme
              //    is registered, not whether the exact app is installed.
              ElevatedButton(
                onPressed: () async {
                  final installed = await LaunchApp.isAppInstalled(
                    androidPackageName: 'com.instagram.android',
                    iosUrlScheme: 'instagram://',
                  );
                  debugPrint('Instagram installed: $installed');
                },
                child: const Text('Is Instagram installed?'),
              ),

              // 3. Android intent URI — use this when you need to pass data to the
              //    target app (action, extras, etc.) rather than just opening it.
              //    The intent string is parsed via Intent.parseUri on the native side.
              //    androidPackageName is optional here; it is only used as a fallback
              //    for the Play Store link when the intent cannot be resolved.
              //    Declare the intent scheme under <queries> in AndroidManifest.xml.
              //
              //    This example opens the Gmail compose screen pre-filled with a
              //    recipient — the S.* extras are string key/value pairs passed to
              //    the target activity.
              ElevatedButton(
                onPressed: () async {
                  // Check first whether any activity resolves the intent.
                  final resolvable = await LaunchApp.isAppInstalled(
                    androidIntentUri:
                        'intent:#Intent;action=android.intent.action.SENDTO;scheme=mailto;package=com.google.android.gm;S.android.intent.extra.EMAIL=support%40example.com;S.android.intent.extra.SUBJECT=Hello;end',
                  );
                  debugPrint('Gmail compose resolvable: $resolvable');

                  if (resolvable) {
                    final result = await LaunchApp.openApp(
                      androidIntentUri:
                          'intent:#Intent;action=android.intent.action.SENDTO;scheme=mailto;package=com.google.android.gm;S.android.intent.extra.EMAIL=support%40example.com;S.android.intent.extra.SUBJECT=Hello;end',
                      androidPackageName: 'com.google.android.gm', // Play Store fallback
                      iosUrlScheme: 'googlegmail://',
                    );
                    debugPrint('openApp (intent URI) result: $result');
                  }
                },
                child: const Text('Compose Gmail (intent URI)'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
```
