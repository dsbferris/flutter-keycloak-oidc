import 'package:example/provider/shared_preferences_provider.dart';
import 'package:example/router.dart';
import 'package:example/screens/loading_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // TODO comment on why path strategy
  usePathUrlStrategy();

  // Show a loading indicator before running the full app
  // If we dont do that, the OS default loading will be shown, but that looks ugly
  // ignore: missing_provider_scope
  runApp(const LoadingScreen());

  // uncomment the delay to view the LoadingScreen
  //await Future.delayed(const Duration(seconds: 3));

  final preferences = await SharedPreferences.getInstance();
  // final manager = await getOidcInstance(preferences);

  return runApp(
    ProviderScope(
      // these overrides provide the magic needed for shared prefs to work
      overrides: [
        // Override the unimplemented provider with the value gotten from the plugin
        sharedPreferencesProvider.overrideWithValue(preferences),
        // oidcUtilityProvider.overrideWithValue(OidcUtility(manager: manager))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    const scheme = FlexScheme.tealM3;
    final themeMode =
        ref.watch(sharedUtilProvider.select((value) => value.themeMode));

    final autorouterConfig =
        ref.watch(appRouterProvider.select((value) => value.config()));

    // go router isn't fully implemented!
    // just wanted to show how it could be done
    // final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: autorouterConfig,
      // routerConfig: goRouter,
      title: "example",
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: FlexThemeData.light(scheme: scheme),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: scheme),
      // Use dark or light theme based on system setting.
    );
  }
}
