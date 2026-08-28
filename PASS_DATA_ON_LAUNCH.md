# Customization need to be done for passing data on launching the application


### 1. Clone the repository to your local

```bash
git clone git@github.com:GeekyAnts/external_app_launcher.git
``` 

### 2. Open the package code on code editor ( Preferrably VS Code)

### 3. Replace the external_app_launcher.dart file with below code

```dart
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
      bool? openStore,
      String? data}) async {
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
      'app_store_link': appStoreLink,
      'data': data
    }).then((value) {
      if (value == "app_opened") {
        print("App opened successfully");
        return 1;
      } else {
        if (value == "navigated_to_store") {
          if (Platform.isIOS) {
            print(
                "Redirecting to AppStore as the app is not present on the device");
          } else
            print(
                "Redirecting to Google Play Store as the app is not present on the device");
        } else {
          print(value);
        }
        return 0;
      }
    });
  }
}

```

### 4. Navigate to /android/src/main/java/com/example/launchexternalapp/LaunchexternalappPlugin.java, Replace the code with below code.

```java
package com.example.launchexternalapp;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import android.app.Activity;
import android.os.Bundle;
import android.content.pm.PackageManager;

import java.util.Map;


/** LaunchExternalAppPlugin */
public class LaunchexternalappPlugin implements MethodCallHandler, FlutterPlugin {

  private static MethodChannel channel;
  private Context context;

  public LaunchexternalappPlugin() {

  }
  private LaunchexternalappPlugin(Context context) {
    this.context = context;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "launch_vpn");
    channel.setMethodCallHandler(new LaunchexternalappPlugin(registrar.activeContext()));
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "launch_vpn");
    channel.setMethodCallHandler(new LaunchexternalappPlugin(flutterPluginBinding.getApplicationContext()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("isAppInstalled")) {
      if (!call.hasArgument("package_name") || TextUtils.isEmpty(call.argument("package_name").toString())) {
        result.error("ERROR", "Empty or null package name", null);
      } else {
        String packageName = call.argument("package_name").toString();
        result.success(isAppInstalled(packageName));
      }
    } else if (call.method.equals("openApp")) {

      String packageName = call.argument("package_name");
      String openStore = call.argument("open_store").toString();
      String data = call.argument("data");
      result.success(openApp(packageName, openStore, data));
    } else {
      result.notImplemented();
    }
  }

  private boolean isAppInstalled(String packageName) {
    try {
      context.getPackageManager().getPackageInfo(packageName, 0);
      return true;
    } catch (PackageManager.NameNotFoundException ignored) {
      return false;
    }
  }

private String openApp(String packageName, String openStore, String data) {
  if (isAppInstalled(packageName)) {
    Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
    if (launchIntent != null) {
      // null pointer check in case package name was not found
      if (data != null) {
          launchIntent.putExtra("data", data);
          Log.d("Data Passed", data);
      }
      launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(launchIntent);
      return "app_opened";
    }
  } else {
    if (openStore != "false") {
      Intent intent1 = new Intent(Intent.ACTION_VIEW);
      intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent1.setData(android.net.Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
      context.startActivity(intent1);
      return "navigated_to_store";
    }
  }
  return "something went wrong";
}
}

```

5. Navigate to /ios/Classes/LaunchexternalappPlugin.m, Replace the code with below code.

```C#
#import "LaunchexternalappPlugin.h"

@implementation LaunchexternalappPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"launch_vpn"
            binaryMessenger:[registrar messenger]];
  LaunchexternalappPlugin* instance = [[LaunchexternalappPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"isAppInstalled" isEqualToString:call.method]) {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]]){
        result(@(YES));
    } else{
        result(@(NO));
    }
  } else if ([@"openApp" isEqualToString:call.method]) {
    @try {
      if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]]) {
        // Create a dictionary with your data to be passed to the launched app
        NSDictionary *dictionary = @{@"key": call.arguments[@"value"]};
        // Convert the dictionary to NSData
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        // Create an options dictionary with the data to be passed to the launched app
        NSDictionary *options = @{UIApplicationLaunchOptionsURLKey: [NSURL URLWithString:call.arguments[@"package_name"]], UIApplicationLaunchOptionsAnnotationKey: data};
        // Launch the app with the options dictionary
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"package_name"]] options:options completionHandler:nil];
        result(@("app_opened"));
      } else {

        NSLog(@"Is reaching here1");
        if(![@"false" isEqualToString: call.arguments[@"open_store"]]) {
          NSLog(@"Is reaching here2 %@", call.arguments[@"app_store_link"]);

          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"app_store_link"]]];
          result(@("navigated_to_store"));
        }
        result(@("App not found in the device"));
      }
    }
    @catch (NSException * e) {
      NSLog(@"exception here");
      result(e);

    }
  } else {
    result(FlutterMethodNotImplemented);
  }

}

@end

```

6. In example app main.dart file change the package name of the application with your preferred app need to be launched.

For Example

```dart
LaunchApp.openApp(
     androidPackageName: 'com.example.secondapp', // package name
     // openStore: false
     data: data,
    );
```

## Changes need to be done on launcher app for recieving the data on launch

### 1. Update your MainActivity.kt file with below code

```kotlin
package com.example.secondapp

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.secondapp/platform"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

   val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
channel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
    if (call.method == "getInitialIntent") {
        val data = handleIntent(intent)
        result.success(data)
    } else {
        result.notImplemented()
    }
}
  }


    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

   private fun handleIntent(intent: Intent): String? {
    if (intent?.extras != null) {
        val data = intent.extras?.getString("data")
        data?.let {
            Log.d("MainActivity", "Received data: $data")
            return data
        }
    }
    return null
}

}

```

### 2. Update your AppDelegate.swift

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let CHANNEL = "com.example.secondapp/platform"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let flutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
        
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            guard call.method == "getInitialIntent" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            let data = self?.handleIntent(intent: launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable : Any])
            result(data)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let data = handleIntent(intent: userActivity.userInfo)
        
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            
            let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
            
            channel.invokeMethod("onNewIntent", arguments: data)
        }
        
        return true
    }
    
    private func handleIntent(intent: [AnyHashable : Any]?) -> String? {
        if let data = intent?["data"] as? String {
            print("Received data: \(data)")
            return data
        }
        return nil
    }
}
```

### 3. Add a function in your main.dart file as below in order to recieve and display the data in your flutter app side.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _initialData = "Static Text";

  @override
  void initState() {
    super.initState();
    handleIntent();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> handleIntent() async {
    // Get initial intent
    final MethodChannel platform =
        MethodChannel('com.example.secondapp/platform');
    try {
      final String? data = await platform.invokeMethod('getInitialIntent');
      if (data != null) {
        setState(() {
          _initialData = data;
        });
      }
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      handleIntent();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_initialData);
    return MaterialApp(
      title: 'Second App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Second App'),
        ),
        body: Center(
          child: Text(_initialData),
        ),
      ),
    );
  }
}

```

4. Your app will be now ready to recieve customized data on launch from another application.