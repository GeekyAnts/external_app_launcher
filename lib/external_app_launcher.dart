import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class LaunchApp {
  /// Method channel declaration
  static const MethodChannel _channel = const MethodChannel('launch_vpn');

  /// Getter for platform version
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Function to check if app is installed on device
  /// returns boolean
  static isAppInstalled(
      {String? iosUrlScheme, String? androidPackageName}) async {
    String packageName = Platform.isIOS ? iosUrlScheme! : androidPackageName!;
    if (packageName.isEmpty) {
      throw Exception('The package name can not be empty');
    }
    dynamic isAppInstalled = await _channel
        .invokeMethod('isAppInstalled', {'package_name': packageName});
    return isAppInstalled;
  }

  /// Function to launch the external app
  /// or redirect to store
  static Future<int> openApp(
      {String? iosUrlScheme,
      String? androidPackageName,
      String? appStoreLink,
      bool? openStore}) async {
    String? packageName = Platform.isIOS ? iosUrlScheme : androidPackageName;
    String packageVariableName =
        Platform.isIOS ? 'iosUrlScheme' : 'androidPackageName';
    if (packageName == null || packageName == "") {
      throw Exception('The $packageVariableName can not be empty');
    }
    if (Platform.isIOS && appStoreLink == null && openStore != false) {
      openStore = false;
    }

    return await _channel.invokeMethod('openApp', {
      'package_name': packageName,
      'open_store': openStore == false ? "false" : "open it",
      'app_store_link': appStoreLink
    }).then((value) {
      if (value == "app_opened") {
        print("app opened successfully");
        return 1;
      } else {
        if (value == "navigated_to_store") {
          if (Platform.isIOS) {
            print(
                "Redirecting to AppStore as the app is not present on the device");
          } else {
            print(
                "Redirecting to Google Play Store as the app is not present on the device");
          }
        } else {
          print(value);
        }
        return 0;
      }
    });
  }

  /// Launches Safari directly on iOS by passing a web URL.
  static Future<int> openSafari({required String url}) async {
    return await openApp(iosUrlScheme: url);
  }

  /// Opens a [url] in a specific browser on Android.
  ///
  /// On Android, pass a [browserPackage] such as `'com.android.chrome'`. If the
  /// specified browser is not installed, the system default browser is used.
  ///
  /// On iOS, pass a browser-specific URL scheme via [iosUrlScheme], e.g.
  /// `googlechrome://` to open Chrome or `googlechromes://example.com`.
  static Future<int> openUrlInBrowser({
    required String url,
    String androidBrowserPackage = '',
    String? iosUrlScheme,
  }) async {
    if (Platform.isIOS) {
      final scheme = iosUrlScheme ?? url;
      return await openApp(iosUrlScheme: scheme);
    }
    final result = await _channel.invokeMethod<String>('openUrlInBrowser', {
      'url': url,
      'browser_package': androidBrowserPackage,
    });
    return result == 'url_opened' ? 1 : 0;
  }

  /// Opens a [url] in Google Chrome.
  ///
  /// On Android, targets `com.android.chrome`. Falls back to system default if
  /// Chrome is not installed.
  /// On iOS, uses the `googlechromes://` URL scheme.
  static Future<int> openUrlInChrome({required String url}) async {
    final iosScheme =
        url.replaceFirst(RegExp(r'^https?://'), 'googlechromes://');
    return await openUrlInBrowser(
      url: url,
      androidBrowserPackage: 'com.android.chrome',
      iosUrlScheme: iosScheme,
    );
  }
}
