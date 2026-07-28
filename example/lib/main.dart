import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';

/// Example app for [external_app_launcher].
///
/// The plugin maps two different native concepts behind one API: iOS uses URL
/// strings (and `LSApplicationQueriesSchemes` in Info.plist for queries),
/// Android uses package names and launch intents. Presets here illustrate both
/// paths without implying one canonical pair of strings for every app.

void main() {
  runApp(const ExampleApp());
}

/// One row of demo data. [iosUrlScheme] is passed through on iOS even when it
/// is a full `https://` URL—the native side builds an `NSURL` from the string.
class AppTarget {
  const AppTarget({
    required this.label,
    required this.iosUrlScheme,
    required this.androidPackageName,
    this.appStoreLink,
  });

  final String label;
  final String iosUrlScheme;
  final String androidPackageName;
  final String? appStoreLink;
}

/// Built-in demos: first entry is for smoke-testing on stock simulators/emulators
/// (no third-party installs). Later entries match the original plugin sample and
/// need the app installed and, on iOS, matching query schemes in Info.plist.
const List<AppTarget> _presets = [
  AppTarget(
    label: 'Apple.com in Safari / Chrome',
    iosUrlScheme: 'https://www.apple.com',
    androidPackageName: 'com.android.chrome',
  ),
  AppTarget(
    label: 'Pulse Secure',
    iosUrlScheme: 'pulsesecure://',
    androidPackageName: 'net.pulsesecure.pulsesecure',
    appStoreLink:
        'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
  ),
  AppTarget(
    label: 'Instagram',
    iosUrlScheme: 'instagram://',
    androidPackageName: 'com.instagram.android',
    appStoreLink: 'itms-apps://itunes.apple.com/us/app/instagram/id389801252',
  ),
];

/// Sentinel for the extra dropdown row; keeps a single [DropdownButton<int>] API
/// without a separate "mode" flag.
const int _kCustomPreset = 3;

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'external_app_launcher example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Defaults to the https/Chrome preset so `flutter run` on a clean simulator
  /// usually does something visible without extra setup.
  int _presetIndex = 0;

  final TextEditingController _iosController = TextEditingController();
  final TextEditingController _androidController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();

  @override
  void dispose() {
    _iosController.dispose();
    _androidController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  AppTarget _effectiveTarget() {
    if (_presetIndex == _kCustomPreset) {
      return AppTarget(
        label: 'Custom',
        iosUrlScheme: _iosController.text.trim(),
        androidPackageName: _androidController.text.trim(),
        appStoreLink: _storeController.text.trim().isEmpty
            ? null
            : _storeController.text.trim(),
      );
    }
    return _presets[_presetIndex];
  }

  void _showSnack(String message, {bool error = false}) {
    // Async gap: [context] is invalid if this State was disposed after await.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  Future<void> _openApp() async {
    final t = _effectiveTarget();
    // Determine what to launch based on platform and target type.
    if (Platform.isIOS) {
      // iOS always uses URL scheme via openApp.
      if (t.iosUrlScheme.isEmpty) {
        _showSnack('Enter an iOS URL or https link.', error: true);
        return;
      }
      try {
        final code = await LaunchApp.openApp(
          iosUrlScheme: t.iosUrlScheme,
          androidPackageName: t.androidPackageName,
          appStoreLink: t.appStoreLink,
        );
        if (!mounted) return;
        if (code == 1) {
          _showSnack('Opened "${t.label}" successfully.');
        } else {
          _showSnack(
              'Did not open the app (not installed, store opened, or blocked).');
        }
      } catch (e) {
        _showSnack('$e', error: true);
      }
    } else {
      // Android: if the target is a plain https URL, open it in the chosen browser.
      final isHttp = t.iosUrlScheme.startsWith('http://') ||
          t.iosUrlScheme.startsWith('https://');
      if (isHttp) {
        try {
          final code = await LaunchApp.openUrlInBrowser(
            url: t.iosUrlScheme,
            androidBrowserPackage: t.androidPackageName,
          );
          if (!mounted) return;
          if (code == 1) {
            _showSnack('Opened "${t.label}" successfully.');
          } else {
            _showSnack('Failed to open URL in browser.');
          }
        } catch (e) {
          _showSnack('$e', error: true);
        }
      } else {
        // Fallback to original behaviour for package name based launch.
        if (t.androidPackageName.isEmpty) {
          _showSnack('Enter an Android package name.', error: true);
          return;
        }
        try {
          final code = await LaunchApp.openApp(
            iosUrlScheme: t.iosUrlScheme,
            androidPackageName: t.androidPackageName,
            appStoreLink: t.appStoreLink,
          );
          if (!mounted) return;
          if (code == 1) {
            _showSnack('Opened "${t.label}" successfully.');
          } else {
            _showSnack(
                'Did not open the app (not installed, store opened, or blocked).');
          }
        } catch (e) {
          _showSnack('$e', error: true);
        }
      }
    }
  }

  /// On iOS, "installed" here follows `canOpenURL` semantics (declared query
  /// schemes, etc.), not a literal install check.
  Future<void> _checkInstalled() async {
    final t = _effectiveTarget();
    final schemeOrPackage =
        Platform.isIOS ? t.iosUrlScheme : t.androidPackageName;
    if (schemeOrPackage.isEmpty) {
      _showSnack(
        Platform.isIOS
            ? 'Enter an iOS URL first.'
            : 'Enter an Android package name first.',
        error: true,
      );
      return;
    }
    try {
      final installed = await LaunchApp.isAppInstalled(
        iosUrlScheme: t.iosUrlScheme,
        androidPackageName: t.androidPackageName,
      );
      if (!mounted) return;
      _showSnack(
        installed
            ? '"${t.label}" can be opened (or is installed).'
            : '"${t.label}" does not appear available.',
      );
    } catch (e) {
      _showSnack('$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _effectiveTarget();
    final isIos = Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('external_app_launcher'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pick an example',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'The first option opens apple.com in Safari (iOS Simulator) or '
            'Chrome (Android emulator).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Example',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _presetIndex,
                items: [
                  ...List.generate(
                    _presets.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(_presets[i].label),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: _kCustomPreset,
                    child: Text('Custom…'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _presetIndex = v);
                },
              ),
            ),
          ),
          if (_presetIndex == _kCustomPreset) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _iosController,
              decoration: const InputDecoration(
                labelText: 'iOS URL',
                hintText: 'https://… or myapp://',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _androidController,
              decoration: const InputDecoration(
                labelText: 'Android package',
                hintText: 'com.example.app',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: 'Store link (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    isIos
                        ? 'iOS: ${t.iosUrlScheme}'
                        : 'Android: ${t.androidPackageName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (t.appStoreLink != null) ...[
                    const SizedBox(height: 4),
                    SelectableText(
                      'Store: ${t.appStoreLink}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _openApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _checkInstalled,
            icon: const Icon(Icons.info_outline),
            label: const Text('Check if available'),
          ),
        ],
      ),
    );
  }
}
