import 'package:flutter/material.dart';
import 'package:launchexternalapp/launchexternalapp.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
              onPressed: () async {
                await LaunchVpn.openApp("com.corona.tracker://", true);
                // Enter thr package name of the App you want to open and for iOS add the URLscheme to the Info.plist file.
                // The second arguments decide wether the app redirects PlayStore or AppStore.
              },
              child: Center(child: Text("Open"))),
        ),
      ),
    );
  }
}
