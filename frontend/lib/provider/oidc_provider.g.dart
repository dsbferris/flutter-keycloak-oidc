// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accessTokenHash() => r'f2a401987a0d02f3f4cbab127ee9bf872aa1132d';

/// See also [accessToken].
@ProviderFor(accessToken)
final accessTokenProvider = AutoDisposeProvider<String?>.internal(
  accessToken,
  name: r'accessTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accessTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AccessTokenRef = AutoDisposeProviderRef<String?>;
String _$currentUserRolesHash() => r'bed59e8d24fbf85e4f30d64b0d8a7306ef7327d5';

/// See also [currentUserRoles].
@ProviderFor(currentUserRoles)
final currentUserRolesProvider = AutoDisposeProvider<List<String>?>.internal(
  currentUserRoles,
  name: r'currentUserRolesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserRolesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRolesRef = AutoDisposeProviderRef<List<String>?>;
String _$currentUserHash() => r'15d77d242dd1dc1ce2d4c1e75cecb0ac85440421';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<OidcUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<OidcUser?>;
String _$authControllerHash() => r'd6997da8f4dbd144bcdda4051a21126a7ac19465';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, OidcUserManager>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AsyncNotifier<OidcUserManager>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
