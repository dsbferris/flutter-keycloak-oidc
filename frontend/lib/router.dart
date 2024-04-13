import 'package:auto_route/auto_route.dart';
import 'package:example/provider/oidc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/screens/login_screen.dart';
import 'package:example/screens/settings_screen.dart';
import 'package:example/screens/home_screen.dart';
import 'package:example/screens/profile_screen.dart';
import 'package:flutter/foundation.dart';

part 'router.gr.dart'; //autoroute

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
    final isLoggedIn = ref.read(userProvider).isLoggedIn;

    if (isLoggedIn) {
      resolver.next();
    } else {
      final didLogin =
          await resolver.redirect<bool?>(LoginRoute(shallPop: true)) ?? false;
      // stop re-pushing any pending routes after current
      resolver.resolveNext(didLogin, reevaluateNext: false);
    }
  }
}
