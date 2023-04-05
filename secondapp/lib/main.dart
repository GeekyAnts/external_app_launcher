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
