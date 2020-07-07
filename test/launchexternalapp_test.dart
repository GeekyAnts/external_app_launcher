import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_external_app/launchexternalapp.dart';

void main() {
  const MethodChannel channel = MethodChannel('launchexternalapp');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LaunchVpn.platformVersion, '42');
  });
}
