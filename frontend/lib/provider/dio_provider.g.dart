// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioClientHash() => r'c94f3addbab61c3083b1ac4194f9ba93ae65983d';

/// See also [dioClient].
@ProviderFor(dioClient)
final dioClientProvider = AutoDisposeProvider<Dio>.internal(
  dioClient,
  name: r'dioClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioClientRef = AutoDisposeProviderRef<Dio>;
String _$dioAuthClientHash() => r'57279897f6bc1c5c8c4a4dcb4f0ae5e8d7ff21c6';

/// See also [dioAuthClient].
@ProviderFor(dioAuthClient)
final dioAuthClientProvider = AutoDisposeFutureProvider<Dio>.internal(
  dioAuthClient,
  name: r'dioAuthClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioAuthClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioAuthClientRef = AutoDisposeFutureProviderRef<Dio>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
