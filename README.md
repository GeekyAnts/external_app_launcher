# launchexternalapp

A Flutter plugin which helps you to open another app from your app

## Getting Started

The package ask your for four parameter out of which 2 are madatory.

## For opening apps in android

For opening an external app from your app in android, you need provide packageName of the app.

If the pluggin found the app in the device it will be be opened but if the the app is not installed in the device then it let the user to playstore link of the app.

> But if you don't want to navigate to playstore if app is not installed then make the `openStore` property to `false`.

## For opening apps in ios

In Ios, for opening an external app from your app, you need to provide URLscheme of the target app.

To know more about URLScheme refer to this [Link](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

In your deployment target is greater than or equal to 9 then also need to update external app information in infoPlist.

    <key>LSApplicationQueriesSchemes</key>
    <array>
    	<string>pulsesecure</string> // url scheme name of the app
    </array>

But like in Android it will not navifate to store(appStore) if app is not found in the device.

For doing so You need to provide the itunes link of the app.

## Additional Feature

Apart from opening an external app.This Package can also be used to check wheather an app installed in the device or not.

This can done by simply calling following code

    await LaunchApp.isAppInstalled(androidPackageName: 'net.pulsesecure.pulsesecure', iosUrlScheme: 'pulsesecure://');

which retuns true and false based on the fact wheather app is installed or not

## Code Illustration

    import 'package:flutter/material.dart';
    import 'package:external_app_launcher/external_app_launcher.    dart';

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
                        androidPackageName: 'net.pulsesecure.   pulsesecure',
                        iosUrlScheme: 'pulsesecure://',
                        appStoreLink:
                            'itms-apps://itunes.apple.com/us/   app/pulse-secure/id945832041',
                        // openStore: false
                      );
                      // Enter thr package name of the App you  want to open and for iOS add the     URLscheme to the Info.plist file.
                      // The second arguments decide wether the     app redirects PlayStore or AppStore.
                      // For testing purpose you can enter com. instagram.android
                    },
                    child: Container(
                        child: Center(
                      child: Text(
                        "Open",
                        textAlign: TextAlign.center,
                      ),
                    ))),
              ),
            ),
          ),
        );
      }
    }
