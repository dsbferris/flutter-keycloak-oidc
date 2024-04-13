import 'dart:io';
import 'package:dio/dio.dart';
import 'package:example/provider/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:example/logger.dart';

part 'oidc_provider.g.dart';

Future<OidcUserManager> getOidcInstance(SharedPreferences preferences) async {
  final keycloakUri =
      Uri.parse('https://keycloak.ferris-s.de/realms/flutter-test/');
  const credentials = OidcClientAuthentication.none(
    clientId: "flutter-test-client",
  );
  // If you want to use form login, you need credentials.
  // But having hard coded credentials in a client app is not good!
  // Better use Browser popup!
  // const credentials = OidcClientAuthentication.clientSecretPost(
  //   clientId: "example-client",
  //   clientSecret: "FpxLDgHwXQhUW9reLZDG2e41yVuylhnb",
  // );

  final htmlPageUri = Uri.parse('http://localhost:22433/redirect.html');

  final redirectUri = kIsWeb
      ? htmlPageUri
      : Platform.isIOS || Platform.isMacOS || Platform.isAndroid
          ? Uri.parse('de.dsbferris.example:/oauth2redirect')
          : Platform.isWindows || Platform.isLinux
              ? Uri.parse('http://localhost:22433')
              : Uri();

  final postLogoutRedirectUri = kIsWeb
      ? htmlPageUri
      : Platform.isAndroid || Platform.isIOS || Platform.isMacOS
          ? Uri.parse('de.dsbferris.example:/endsessionredirect')
          : Platform.isWindows || Platform.isLinux
              ? Uri.parse('http://localhost:22433')
              : null;

  final frontChannelLogoutUri = kIsWeb
      ? htmlPageUri.replace(queryParameters: {
          ...htmlPageUri.queryParameters,
          'requestType': 'front-channel-logout'
        })
      : null;

  final manager = OidcUserManager.lazy(
    discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
      keycloakUri,
    ),
    clientCredentials: credentials,
    store: OidcDefaultStore(
      sharedPreferences: preferences,
      secureStorageInstance: const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
    settings: OidcUserManagerSettings(
      redirectUri: redirectUri,
      postLogoutRedirectUri: postLogoutRedirectUri,
      frontChannelLogoutUri: frontChannelLogoutUri,
      strictJwtVerification: true,
    ),
  );

  logger.t("running oidc init");
  await manager.init();
  return manager;
}

@riverpod
OidcUserManager userManager(UserManagerRef ref) {
  throw UnimplementedError();
}

@riverpod
OidcUser? user(UserRef ref) {
  return ref.watch(userManagerProvider.select((value) => value.currentUser));
}

@riverpod
bool isUserLoggedIn(IsUserLoggedInRef ref) {
  return ref.watch(userProvider) != null;
}

extension MyUserWithRoles on OidcUser {
  List<String>? get roles {
    if (token.accessToken == null) return null;
    var jwt = JsonWebToken.unverified(token.accessToken!);
    final realmAccess =
        jwt.claims.getTyped<Map<String, dynamic>>("realm_access");
    if (realmAccess == null) return null;

    final rolesDyn = realmAccess["roles"] as List<dynamic>?;
    if (rolesDyn == null) return null;
    return List<String>.from(rolesDyn);
  }
}

extension IsLoggedInUser on OidcUser? {
  bool get isLoggedIn => this != null;
}

class MyManager {
  final WidgetRef ref;

  MyManager(this.ref);

  @Deprecated(
      "This is unsecure. Use loginPopup with the secure AuthorizationCodeFlow")
  Future<OidcUser?> loginForm(
      {required String username, required String password}) async {
    final manager = ref.read(userManagerProvider);
    if (username.isEmpty || password.isEmpty) {
      return null;
    }
    final user = await manager
        .loginPassword(username: username, password: password)
        .catchError((err) {
      logger.e(err);
      return null;
    });
    return user;
  }

  Future<OidcUser?> loginPopup() async {
    final manager = ref.read(userManagerProvider);
    final user = await manager.loginAuthorizationCodeFlow().catchError((err) {
      logger.e(err);
      return null;
    });
    logger.i("user login successful");
    return user;
  }

  Future<void> logout() {
    if (kIsWeb) {
      return logoutPopup();
    }
    return logoutSilent();
  }

  Future<void> logoutPopup({Uri? originalUri}) async {
    final manager = ref.read(userManagerProvider);
    await manager.logout().catchError((err) {
      logger.e(err);
      return null;
    });
    // ref.invalidate(currentUserProvider);
    logger.i("logged out user");
  }

  Future<void> logoutSilent() async {
    final manager = ref.read(userManagerProvider);
    final endpoint = manager.discoveryDocument.endSessionEndpoint.toString();
    final logoutUri = Uri.parse(endpoint).replace(queryParameters: {
      "id_token_hint": manager.currentUser!.idToken,
    });
    final dio = ref.read(dioClientProvider);
    // keycloak returns a html doc

    final dioResp = await dio.getUri<String>(logoutUri).catchError((err) {
      logger.e(err);
      return Response<String>(requestOptions: RequestOptions(), data: "");
    });
    final body = dioResp.data ?? "";
    if (!body.contains("You are logged out")) {
      logger.e("logout did not work...");
      return;
    } else {
      logger.i("sent logout to keycloak");
      await forgetUser();
    }
  }

  Future<void> forgetUser() async {
    final manager = ref.read(userManagerProvider);
    await manager.forgetUser();
    logger.i("forgot user");
  }

  Future<OidcUser?> refreshToken() async {
    final manager = ref.read(userManagerProvider);
    final user = await manager.refreshToken().catchError((err) {
      logger.e(err);
      return null;
    });
    logger.i("refreshed token");
    return user;
  }
}
