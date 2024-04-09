import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:example/app.dart';
import 'package:example/provider/shared_preferences_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:example/screens/loading_screen.dart';

/*
void main() {
  if (kIsWeb) {
    //runApp(const MyMaterialApp());
    runApp(const ProviderScope(child: MyApp()));
  } else if (Platform.isIOS || Platform.isMacOS) {
    runApp(const ProviderScope(child: MyApp()));
  } else {
    //runApp(const MyMaterialApp());
    runApp(const ProviderScope(child: MyApp()));
  }
}
 */

Future<void> main() async {
  usePathUrlStrategy();
  // usually it would just be:
  //    runApp(const MyApp());
  // but getting that shared preferences instance is is async
  // and therefore creates this mess...

  // Show a loading indicator before running the full app
  // If we dont do that, the OS default loading will be shown, but that looks ugly
  // ignore: missing_provider_scope
  runApp(const LoadingScreen());

  // uncomment the delay to view the LoadingScreen
  //await Future.delayed(const Duration(seconds: 3));

  final preferences = await SharedPreferences.getInstance();

  return runApp(
    ProviderScope(
      // these overrides provide the magic needed for shared prefs to work
      overrides: [
        // Override the unimplemented provider with the value gotten from the plugin
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MyApp(),
    ),
  );
}
