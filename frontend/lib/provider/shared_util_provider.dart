import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_util_provider.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError();

@riverpod
class MyThemeMode extends _$MyThemeMode {
  static const String _themeModeKey = "myThemeMode";
  @override
  ThemeMode build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    final savedIndex = preferences.getInt(_themeModeKey);
    return savedIndex != null && savedIndex < ThemeMode.values.length
        ? ThemeMode.values[savedIndex]
        : ThemeMode.system;
  }

  Future<void> set(ThemeMode? value) async {
    if (value != null && value != state) {
      final preferences = ref.read(sharedPreferencesProvider);
      if (await preferences.setInt(_themeModeKey, value.index)) {
        state = value;
      }
    }
  }
}
