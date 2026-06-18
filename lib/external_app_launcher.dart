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

  /// Returns whether the target can be opened or resolved.
  ///
  /// **Android:** pass [androidPackageName], or [androidIntentUri] for an
  /// `intent://…#Intent;…;end` string (resolved with Android `Intent.parseUri`).
  ///
  /// **iOS:** pass [iosUrlScheme] as a custom scheme URL. It may include a path
  /// and query (e.g. `myapp://pay?code=…`) for deep links; declare the **scheme**
  /// under `LSApplicationQueriesSchemes` in Info.plist.
  static Future<dynamic> isAppInstalled({
    String? iosUrlScheme,
    String? androidPackageName,
    String? androidIntentUri,
  }) async {
    if (Platform.isAndroid) {
      final hasIntent = androidIntentUri != null && androidIntentUri.isNotEmpty;
      final hasPkg =
          androidPackageName != null && androidPackageName.isNotEmpty;
      if (!hasIntent && !hasPkg) {
        throw Exception(
            'Either androidPackageName or androidIntentUri is required');
      }
      if (hasIntent) {
        return _channel.invokeMethod('isAppInstalled', {
          'android_intent_uri': androidIntentUri,
        });
      }
    } else {
      if (iosUrlScheme == null || iosUrlScheme.isEmpty) {
        throw Exception('The iosUrlScheme can not be empty');
      }
    }
    final String packageName =
        Platform.isIOS ? iosUrlScheme! : androidPackageName!;
    return _channel.invokeMethod('isAppInstalled', {
      'package_name': packageName,
    });
  }

  /// Launches another app, or may redirect to a store when the app is missing.
  ///
  /// **Android:** provide [androidPackageName] for a normal launch, **or**
  /// [androidIntentUri] for a full intent URI (extras embedded in the URI per
  /// Android’s intent scheme). You can pass both: the intent is tried first;
  /// [androidPackageName] may be used for Play Store fallback.
  ///
  /// **iOS:** [iosUrlScheme] is sent to the system as a URL string; include query
  /// parameters for deep-link data when the target app supports them.
  static Future<int> openApp({
    String? iosUrlScheme,
    String? androidPackageName,
    String? androidIntentUri,
    String? appStoreLink,
    bool? openStore,
  }) async {
    if (Platform.isAndroid) {
      final hasIntent = androidIntentUri != null && androidIntentUri.isNotEmpty;
      final hasPkg =
          androidPackageName != null && androidPackageName.isNotEmpty;
      if (!hasIntent && !hasPkg) {
        throw Exception(
            'Either androidPackageName or androidIntentUri is required');
      }
    } else {
      if (iosUrlScheme == null || iosUrlScheme.isEmpty) {
        throw Exception('The iosUrlScheme can not be empty');
      }
    }
    if (Platform.isIOS && appStoreLink == null && openStore != false) {
      openStore = false;
    }

    final Map<String, dynamic> args = {
      'open_store': openStore == false ? "false" : "open it",
      'app_store_link': appStoreLink,
    };
    if (Platform.isAndroid &&
        androidIntentUri != null &&
        androidIntentUri.isNotEmpty) {
      args['android_intent_uri'] = androidIntentUri;
      args['package_name'] = androidPackageName ?? '';
    } else {
      args['package_name'] =
          Platform.isIOS ? iosUrlScheme! : androidPackageName!;
    }

    try {
      final value = await _channel.invokeMethod('openApp', args);
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
    } on PlatformException catch (e) {
      // Thrown by the Flutter framework when the native side calls result.error().
      print("Failed to open app: ${e.message}");
      return 0;
    } catch (e) {
      // Catches MissingPluginException (plugin not registered) and anything else unexpected.
      print("Failed to open app: $e");
      return 0;
    }
  }
}
