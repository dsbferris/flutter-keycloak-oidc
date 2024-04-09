import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/provider/oidc_provider.dart';
import 'package:example/screens/login_screen.dart';
import 'package:example/screens/settings_screen.dart';
import 'package:example/screens/home_screen.dart';
import 'package:example/screens/profile_screen.dart';
import 'package:flutter/foundation.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  WidgetRef ref;

  AppRouter(this.ref) : super();

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
          guards: [MyAppGuard(ref)],
        ),
      ];
}

class MyAppGuard implements AutoRouteGuard {
  MyAppGuard(this.ref) : super();
  final WidgetRef ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // final isAuthenticated = ref.read(loggedInProvider);

    var user = ref.read(currentUserProvider);
    final isAuthenticated = user != null;
    if (isAuthenticated) {
      resolver.next();
    } else {
      await resolver.redirect(LoginRoute(shallPop: true));
      user = ref.read(currentUserProvider);
      final didLogin = user != null;
      // stop re-pushing any pending routes after current
      resolver.resolveNext(didLogin, reevaluateNext: false);
    }
  }
}
