// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userManagerHash() => r'2c682dbfbed202eb2479d7ad5630a90963246033';

/// See also [userManager].
@ProviderFor(userManager)
final userManagerProvider = AutoDisposeProvider<OidcUserManager>.internal(
  userManager,
  name: r'userManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserManagerRef = AutoDisposeProviderRef<OidcUserManager>;
String _$userHash() => r'c192ccee4a5433b195bfdf5dc60f00a8566c960a';

/// See also [user].
@ProviderFor(user)
final userProvider = AutoDisposeProvider<OidcUser?>.internal(
  user,
  name: r'userProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRef = AutoDisposeProviderRef<OidcUser?>;
String _$isUserLoggedInHash() => r'193982aebab02c7c084168f7570ae20d928f2828';

/// See also [isUserLoggedIn].
@ProviderFor(isUserLoggedIn)
final isUserLoggedInProvider = AutoDisposeProvider<bool>.internal(
  isUserLoggedIn,
  name: r'isUserLoggedInProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isUserLoggedInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsUserLoggedInRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
