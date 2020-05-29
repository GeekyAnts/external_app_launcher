import 'dart:async';

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

    int isAppInstalled = await _channel
        .invokeMethod('isAppInstalled', {'package_name': packageName});
    return isAppInstalled;
  }

  static Future<int> openApp(String packageName) async {
    if (packageName.isEmpty) {
      throw Exception('The package name can not be empty');
    }
    return await _channel
        .invokeMethod('openApp', {'package_name': packageName});
  }
}
