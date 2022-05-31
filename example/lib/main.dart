import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
          child: SizedBox(
            height: 50,
            width: 150,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                onPressed: () async {
                  await LaunchApp.openApp(
                    androidPackageName: 'net.pulsesecure.pulsesecure',
                    iosUrlScheme: 'pulsesecure://',
                    appStoreLink:
                        'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
                    // openStore: false
                  );
                  // Enter thr package name of the App you want to open and for iOS add the URLscheme to the Info.plist file.
                  // The second arguments decide wether the app redirects PlayStore or AppStore.
                  // For testing purpose you can enter com.instagram.android
                },
                child: const Center(
                  child: Text(
                    "Open",
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
