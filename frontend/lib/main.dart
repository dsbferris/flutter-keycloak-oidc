import 'package:example/provider/shared_util_provider.dart';
import 'package:example/router.dart';
import 'package:example/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // path strategy needed for web and go router
  setPathUrlStrategy();

  // Show a loading indicator before running the full app.
  // If we dont do that, the OS default loading will be shown, and that looks ugly...
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(myThemeModeProvider);

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
      theme: ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
