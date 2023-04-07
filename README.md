## Overview

A Flutter plugin which helps you to open another app from your app. The package asks you for four parameters out of which two are mandatory.

## Getting Started

## 1. Add package to your project

Complete description to add this package to your project can be found [here](https://pub.dev/packages/external_app_launcher/install).

## 2. To setup native performance for the application in order to launch external apps

## For opening apps in android

For opening an external app from your app in android, you need provide packageName of the app.

If the plugin finds the app in the device, it will be be launched. But if the the app is not installed in the device then it leads the user to playstore link of the app.

> But if you don't want to redirect to playstore after installation then add the below script to `AndroidManifest.xml` file.
     
     <queries>
       <package android:name="net.pulsesecure.pulsesecure" /> // your android package name
     </queries>
    
    // Above <application> tag
    
    // Inside <intent-filter> add below existing <action> or <category>
    <category android:name="android.intent.category.HOME"/> 
    <category android:name="android.intent.category.DEFAULT"/>

## Demo

<img src="https://user-images.githubusercontent.com/60135944/171337872-81b89d2c-2c8b-4ecf-9702-33788821124c.gif" width="400"/>

## For opening apps in ios

In iOS, for opening an external app from your app, you need to provide URLscheme of the target app.

To know more about URLScheme refer to this [Link](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

If your deployment target is greater than or equal to 9, then you also need to update external app information in `Info.plist`.

    <key>LSApplicationQueriesSchemes</key>
    <array>
      <string>pulsesecure</string> // url scheme name of the app
    </array>

But unlike in Android, it will not navigate to store (appStore) if app is not found in the device.

For doing so you need to provide the iTunes link of the app.
## Demo

<img src="https://user-images.githubusercontent.com/60135944/171337798-bdf3f78d-d002-4353-aab3-8b07dd688916.gif" width="400"/>

## Implementation

Apart from opening an external app, this package can also be used to check whether an app is installed in the device or not.

This can done by simply calling the function `isAppInstalled`

    await LaunchApp.isAppInstalled(
      androidPackageName: 'net.pulsesecure.pulsesecure'
      iosUrlScheme: 'pulsesecure://'
    );

This returns true and false based on the fact whether app is installed or not.

## Code Illustration

    import 'package:flutter/material.dart';
    import 'package:external_app_launcher/external_app_launcher.dart';

    void main() {
      runApp(MyApp());
    }

    class MyApp extends StatefulWidget {
      @override
      _MyAppState createState() => _MyAppState();
    }

    class _MyAppState extends State<MyApp> {
      @override
      void initState() {
        super.initState();
      }

      Color containerColor = Colors.red;

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: Container(
                height: 50,
                width: 150,
                child: RaisedButton(
                  color: Colors.blue,
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'net.pulsesecure.pulsesecure',
                      iosUrlScheme: 'pulsesecure://',
                      appStoreLink: 'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
                      // openStore: false
                    );

                    // Enter the package name of the App you want to open and for iOS add the URLscheme to the Info.plist file.
                    // The `openStore` argument decides whether the app redirects to PlayStore or AppStore.
                    // For testing purpose you can enter com.instagram.android
                  },
                  child: Container(
                    child: Center(
                      child: Text("Open",
                        textAlign: TextAlign.center,
                      ),
                    ))),
              ),
            ),
          ),
        );
      }
    }

## If you want to pass data while launching an external app using this package, you can customize it by following the steps mentioned in the [DOCS](PASS_DATA_ON_LAUNCH.md).