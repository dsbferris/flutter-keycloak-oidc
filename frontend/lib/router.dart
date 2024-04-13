import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/provider/oidc_provider.dart';
import 'package:example/screens/login_screen.dart';
import 'package:example/screens/settings_screen.dart';
import 'package:example/screens/home_screen.dart';
import 'package:example/screens/profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:oidc/oidc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.gr.dart'; //autoroute
part 'router.g.dart'; //go router

final appRouterProvider = Provider<AppRouter>((ref) => AppRouter(ref));

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  AppRouter(this.ref) : super();

  Ref ref;

  @override
  RouteType get defaultRouteType =>
      const RouteType.adaptive(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          path: "/",
          initial: true,
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: "/settings",
        ),
        AutoRoute(
          page: LoginRoute.page,
          path: "/login",
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: "/profile",
          guards: [NeedsAuth(ref)],
        ),
      ];
}

class NeedsAuth implements AutoRouteGuard {
  NeedsAuth(this.ref) : super();
  final Ref ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    var user = ref.read(currentUserProvider).valueOrNull;

    final authenticated = user != null;
    if (authenticated) {
      resolver.next();
    } else {
      await resolver.redirect(LoginRoute(shallPop: true));
      var user = ref.read(currentUserProvider).valueOrNull;
      final didLogin = user != null;
      // stop re-pushing any pending routes after current
      resolver.resolveNext(didLogin, reevaluateNext: false);
    }
  }
}

/// go router isn't fully implemented!
/// just wanted to show how it could be done
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(routes: [
    GoRoute(
      path: "/",
      name: "home",
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: "/settings",
      name: "settings",
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: "/login",
      name: "login",
      builder: (context, state) => const LoginScreen(shallPop: false),
      redirect: (context, state) {
        // TODO FIX
        final authenticated = ref.read(currentUserProvider) != null;
        if (authenticated) {
          final originalUri =
              state.uri.queryParameters[OidcConstants_Store.originalUri];
          if (originalUri != null) {
            return originalUri;
          }
        }
        return null;
      },
    ),
    GoRoute(
      path: "/profile",
      name: "profile",
      builder: (context, state) => const ProfileScreen(),
      redirect: (context, state) {
        final authenticated = ref.read(currentUserProvider) != null;

        if (!authenticated) {
          final uri = Uri(
            path: '/login',
            queryParameters: {
              // Note that this requires setPathUrlStrategy(); from `package:url_strategy`
              // and set
              OidcConstants_Store.originalUri: state.uri.toString(),
            },
          );
          return uri.toString();
        }
        return null;
      },
    )
  ]);
}
