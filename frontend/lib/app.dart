import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/provider/theme_mode_provider.dart';
import 'package:example/router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const scheme = FlexScheme.tealM3;
    return MaterialApp.router(
      routerConfig: AppRouter(ref).config(),
      title: "example",
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeStateProvider),
      theme: FlexThemeData.light(scheme: scheme),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: scheme),
      // Use dark or light theme based on system setting.
    );
  }
}
