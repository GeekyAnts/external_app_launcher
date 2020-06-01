import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class LaunchVpn {
  static const MethodChannel _channel = const MethodChannel('launch_vpn');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> isAppInstalled(String packageName) async {
    if (packageName.isEmpty) {
      throw Exception('The package name can not be empty');
    }
    int isAppInstalled =
        await _channel.invokeMethod('isAppInstalled', {'package_name': packageName});
    return isAppInstalled;
  }

  static Future<int> openApp(String packageName, bool openStore) async {
    if (packageName.isEmpty) {
      throw Exception('The package name can not be empty');
    }
    int installed = await isAppInstalled(packageName);
    print("----------- $installed");

    if (installed != 1 && !openStore)
      throw Exception('The package $packageName was not found on the device');
    else {
      return await _channel.invokeMethod('openApp', {'package_name': packageName}).then((value) {
        if (Platform.isIOS)
          throw Exception("Redirecting to AppStore as the App is not present on the device");
        else
          throw Exception(
              "Redirecting to Google PlayStore as the App is not present on the device");
      });
    }
  }
}
