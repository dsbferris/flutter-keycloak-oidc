// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_util_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'75e745127707e465d3f55ce89ddcc932bd72bc2d';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$myThemeModeHash() => r'd1974d543e77384a34376ae2efaa51f21991c9b0';

/// See also [MyThemeMode].
@ProviderFor(MyThemeMode)
final myThemeModeProvider =
    AutoDisposeNotifierProvider<MyThemeMode, ThemeMode>.internal(
  MyThemeMode.new,
  name: r'myThemeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyThemeMode = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
