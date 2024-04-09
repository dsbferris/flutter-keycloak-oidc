// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserHash() => r'1808b4fc6adb4403f40e4fe47b1d9895f7a1a1c1';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = Provider<OidcUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = ProviderRef<OidcUser?>;
String _$oidcHash() => r'cfb54ff03116bb1e143ec039720f6b175dff2c97';

/// See also [Oidc].
@ProviderFor(Oidc)
final oidcProvider = NotifierProvider<Oidc, OidcUserManager>.internal(
  Oidc.new,
  name: r'oidcProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$oidcHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Oidc = Notifier<OidcUserManager>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
