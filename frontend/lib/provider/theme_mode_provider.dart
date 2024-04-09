import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/provider/shared_preferences_provider.dart';

part 'theme_mode_provider.g.dart';

@riverpod
class ThemeModeState extends _$ThemeModeState {
  @override
  ThemeMode build() {
    // 0 = system
    // 1 = light
    // 2 = dark
    final preferences = ref.watch(sharedPreferencesProvider);
    final currentValue = preferences.getInt('themeMode') ?? 0;
    final currentThemeMode = currentValue == 0
        ? ThemeMode.system
        : currentValue == 1
            ? ThemeMode.light
            : ThemeMode.dark;
    return currentThemeMode;
  }

  void update(ThemeMode t) {
    state = t;
    final value = t == ThemeMode.system
        ? 0
        : t == ThemeMode.light
            ? 1
            : 2;
    final preferences = ref.watch(sharedPreferencesProvider);
    preferences.setInt('themeMode', value);
  }
}

// final themeModeProvider = StateProvider<ThemeMode>((ref) {
//   // 0 = system
//   // 1 = light
//   // 2 = dark
//   final preferences = ref.watch(sharedPreferencesProvider);
//   final currentValue = preferences.getInt('themeMode') ?? 0;
//   final currentThemeMode = currentValue == 0
//       ? ThemeMode.system
//       : currentValue == 1
//           ? ThemeMode.light
//           : ThemeMode.dark;
//   ref.listenSelf((prev, curr) {
//     final value = curr == ThemeMode.system
//         ? 0
//         : curr == ThemeMode.light
//             ? 1
//             : 2;
//     preferences.setInt('themeMode', value);
//   });
//   return currentThemeMode;
// });
