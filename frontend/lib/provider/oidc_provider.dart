import 'dart:io';
import 'package:example/provider/dio_provider.dart';
import 'package:example/provider/shared_util_provider.dart';
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
        options: _options(),
        strictJwtVerification: true),
    //keyStore: JsonWebKeyStore(),
  );

  logger.t("running oidc init");
  await manager.init();
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

@riverpod
String? accessToken(AccessTokenRef ref) {
  return ref
      .watch(currentUserProvider.select((value) => value?.token.accessToken));
}

@riverpod
List<String>? currentUserRoles(CurrentUserRolesRef ref) {
  return ref.watch(currentUserProvider.select((value) => _getRoles(value)));
}

List<String>? _getRoles(OidcUser? user) {
  // tell me you like golang with telling me

  if (user == null) return null;

  final accessToken = user.token.accessToken;
  if (accessToken == null) return null;

  var jwt = JsonWebToken.unverified(accessToken);

  final realmAccess = jwt.claims.getTyped<Map<String, dynamic>>("realm_access");
  if (realmAccess == null) return null;

  final rolesDyn = realmAccess["roles"] as List<dynamic>?;
  if (rolesDyn == null) return null;

  return List<String>.from(rolesDyn);
}

@riverpod
OidcUser? currentUser(CurrentUserRef ref) {
  // workaround to get rid of that AsyncValue
  return ref.watch(authControllerProvider.select((value) {
    if (value.hasError || value.isLoading || !value.hasValue) {
      return null;
    }
    return value.requireValue.currentUser;
  }));
}

// Use [AuthController] only with ref.read(authControllerProvider.notifier).method
// To get current user etc. use the above!

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<OidcUserManager> build() async {
    final manager = await getOidcInstance(ref.watch(sharedPreferencesProvider));
    manager.userChanges().listen((user) {
      // update currentUser
      logger.t("user changed");
      logger.t(user?.userInfo);
      ref.notifyListeners();
    });
    return manager;
  }

  @Deprecated(
      "This is unsecure. Use loginPopup with the secure AuthorizationCodeFlow")
  Future<OidcUser?> loginForm(String username, String password) async {
    final manager = state.requireValue;
    if (username.isEmpty || password.isEmpty) {
      return null;
    }
    final user =
        await manager.loginPassword(username: username, password: password);
    return user;
  }

  Future<OidcUser?> loginPopup(Uri? originalUri) async {
    final manager = state.requireValue;
    final user = await manager.loginAuthorizationCodeFlow(
      originalUri: originalUri ?? Uri.parse('/'),
      //store any arbitrary data, here we store the authorization start time.
      extraStateData: DateTime.now().toIso8601String(),
      options: _options(),
    );
    logger.i("user login successful");
    return user;
  }

  Future<void> logout() {
    if (kIsWeb) {
      return logoutPopup();
    }
    return logoutSilent();
  }

  Future<void> logoutPopup() async {
    final manager = state.requireValue;
    await manager.logout(originalUri: Uri.parse('/'), options: _options());
    // ref.invalidate(currentUserProvider);
    logger.i("logged out user");
  }

  Future<void> logoutSilent() async {
    final manager = state.requireValue;
    final endpoint = manager.discoveryDocument.endSessionEndpoint.toString();
    final logoutUri = Uri.parse(endpoint).replace(queryParameters: {
      "id_token_hint": manager.currentUser!.idToken,
    });
    final dio = ref.read(dioClientProvider);
    // keycloak returns a html doc
    final dioResp = await dio.getUri<String>(logoutUri);
    final body = dioResp.data ?? "";
    if (!body.contains("You are logged out")) {
      throw Exception("logout did not work...");
    }
    logger.i("sent logout to keycloak");
    await forgetUser();
  }

  Future<void> forgetUser() async {
    final manager = state.requireValue;
    await manager.forgetUser();
    logger.i("forgot user");
  }

  Future<OidcUser?> refreshToken() async {
    final manager = state.requireValue;
    final user = await manager.refreshToken();
    logger.i("refreshed token");
    return user;
  }
}
