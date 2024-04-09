import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:example/logger.dart';
import 'package:example/provider/shared_preferences_provider.dart';

part 'oidc_provider.g.dart';

@Riverpod(keepAlive: true)
OidcUser? currentUser(CurrentUserRef ref) {
  return ref.watch(oidcProvider.select((value) => value.currentUser));
}

@Riverpod(keepAlive: true)
class Oidc extends _$Oidc {
  // bool _loginViaPopup = false;

  @override
  OidcUserManager build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _getOidcInstance(prefs);
  }

  Future<void> _init() async {
    final manager = state;
    logger.t("running oidc init");
    await manager.init();
    logger.t("finished oidc init");
    manager.userChanges().listen((user) {
      // update currentUser
      logger.t("user changed");
      logger.t(user?.userInfo);
      ref.notifyListeners();
    });
  }

  @Deprecated(
      "This is unsecure and shall not be used anymore. Use loginPopup with the secure AuthorizationCodeFlow")
  Future<OidcUser?> loginForm(String username, String password) async {
    final manager = state;
    try {
      if (!manager.didInit) {
        await _init();
      }
      if (username.isEmpty || password.isEmpty) return null;
      final user =
          await manager.loginPassword(username: username, password: password);

      final roles = _getRoles();
      user?.userInfo.addAll(roles);
      ref.invalidate(currentUserProvider);

      return user;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return null;
  }

  Future<OidcUser?> loginPopup() async {
    final manager = state;
    try {
      if (!manager.didInit) {
        await _init();
      }
      logger.t("running login popup");
      final user = await manager.loginAuthorizationCodeFlow(
        originalUri: Uri.parse('/'),
        //store any arbitrary data, here we store the authorization start time.
        extraStateData: DateTime.now().toIso8601String(),
        options: _options(),
      );

      logger.i("user login successful");

      final roles = _getRoles();
      user?.userInfo.addAll(roles);
      ref.invalidate(currentUserProvider);

      return user;
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  Map<String, List<String>> _getRoles() {
    final manager = state;
    final accessToken = manager.currentUser?.token.accessToken;
    if (accessToken != null) {
      var jwt = JsonWebToken.unverified(accessToken);
      final realmAccess =
          jwt.claims.getTyped<Map<String, dynamic>>("realm_access");
      if (realmAccess != null) {
        final rolesDyn = realmAccess["roles"] as List<dynamic>?;
        if (rolesDyn != null) {
          final roles = List<String>.from(rolesDyn);
          return {"roles": roles};
        }
      }
    }
    return {};
  }

  Future<void> logout() {
    if (kIsWeb) {
      return _logoutPopup();
    }
    return _logoutSilent();
  }

  Future<void> _logoutPopup() async {
    final manager = state;
    try {
      if (!manager.didInit) {
        await _init();
      }
      await manager.logout(originalUri: Uri.parse('/'), options: _options());
      // ref.invalidate(currentUserProvider);
      logger.i("user logout successful");
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> _logoutSilent() async {
    final manager = state;
    try {
      if (!manager.didInit) {
        await _init();
      }
      final endpoint = manager.discoveryDocument.endSessionEndpoint.toString();
      final logoutUri = Uri.parse(endpoint).replace(queryParameters: {
        "id_token_hint": manager.currentUser!.idToken,
      });

      final resp = await http.get(logoutUri);
      final body = resp.body;
      if (!body.contains("You are logged out")) {
        throw Exception("logout did not work...");
      }
      await _forgetUser();
      logger.i("user logout successful");
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> _forgetUser() async {
    final manager = state;
    await manager.forgetUser();
    // ref.notifyListeners();
    // ref.invalidate(currentUserProvider);
  }
}

OidcUserManager _getOidcInstance(SharedPreferences? preferences) {
  // TODO you need to adjust these
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
        options: _options(),
        strictJwtVerification: true),
    //keyStore: JsonWebKeyStore(),
  );

  return manager;
}

OidcPlatformSpecificOptions _options() {
  return const OidcPlatformSpecificOptions(
    ios: OidcPlatformSpecificOptions_AppAuth_IosMacos(
      preferEphemeralSession: true,
    ),
    macos: OidcPlatformSpecificOptions_AppAuth_IosMacos(
      preferEphemeralSession: true,
    ),
  );
}
