import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

// final sharedPreferencesProvider =
//     Provider<SharedPreferences>((ref) => throw UnimplementedError());

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError();

@riverpod
SharedUtil sharedUtil(SharedUtilRef ref) {
  return SharedUtil(ref.watch(sharedPreferencesProvider));
}

class SharedUtil {
  SharedUtil(this.preferences);

  final SharedPreferences preferences;

  static const String _themeModeKey = "themeMode";

  ThemeMode get themeMode {
    final value = preferences.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[value];
  }

  Future<bool> setThemeMode(ThemeMode value) {
    return preferences.setInt(_themeModeKey, value.index);
  }
}
