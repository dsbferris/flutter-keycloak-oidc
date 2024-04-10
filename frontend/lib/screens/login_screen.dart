import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:example/provider/oidc_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:oidc/oidc.dart';

@RoutePage()
class LoginScreen extends ConsumerWidget {
  const LoginScreen({this.shallPop = false, super.key});

  final bool shallPop;

  void resetManager(BuildContext context, WidgetRef ref) {
    ref.invalidate(authControllerProvider);
  }

  Future<void> loginPopup(BuildContext context, WidgetRef ref) async {
    final goRouter = GoRouter.maybeOf(context);
    Uri? parsedOriginalUri;
    if (goRouter != null) {
      final currentRoute = GoRouterState.of(context);
      final originalUri =
          currentRoute.uri.queryParameters[OidcConstants_Store.originalUri];
      parsedOriginalUri =
          originalUri == null ? null : Uri.tryParse(originalUri);
    }

    await ref
        .read(authControllerProvider.notifier)
        .loginPopup(parsedOriginalUri);

    if (shallPop && context.mounted) {
      await AutoRouter.of(context).maybePop();
    }
  }

  Future<void> refreshToken(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).refreshToken();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ElevatedButton(
              onPressed: () => resetManager(context, ref),
              child: const Text("Reset oidc manager (testing)"),
            ),
            const Gap(4),
            Visibility(
                visible: user == null,
                child: Column(
                  children: [
                    UserLoginForm(shallPop),
                    ElevatedButton(
                      onPressed: () async => await loginPopup(context, ref),
                      child: const Text("Login Browser Popup"),
                    ),
                  ],
                )),
            const Gap(4),
            Visibility(
              visible: user != null,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async => await refreshToken(context, ref),
                    child: const Text("Refresh Token manually"),
                  ),
                  const Gap(4),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
            const Divider(),
            UserInfoTexts(user),
          ],
        ),
      ),
    );
  }
}

class UserLoginForm extends ConsumerStatefulWidget {
  const UserLoginForm(this.shallPop, {super.key});

  final bool shallPop;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserLoginFormState();
}

class _UserLoginFormState extends ConsumerState<UserLoginForm> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool usernameIsEmail = false;

  Future<void> loginForm(BuildContext context, WidgetRef ref) async {
    await ref
        .read(authControllerProvider.notifier)
        .loginForm(userNameController.text, passwordController.text);
    if (widget.shallPop && context.mounted) {
      await AutoRouter.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Column(
        children: [
          Column(
            children: [
              Text(
                "Using the form is depracted. Please use Browser popup!",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("username is email"),
                  const Gap(20),
                  Switch.adaptive(
                    value: usernameIsEmail,
                    onChanged: (_) {
                      setState(() {
                        usernameIsEmail = !usernameIsEmail;
                      });
                    },
                  ),
                ],
              ),
              const Gap(4),
              TextFormField(
                controller: userNameController,
                autocorrect: false,
                autofillHints: const ["username"],
                keyboardType: usernameIsEmail
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: usernameIsEmail ? "email" : "username",
                  hintText: usernameIsEmail ? "email" : "username",
                ),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: passwordController,
                autocorrect: false,
                autofillHints: const ["password"],
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "password",
                  hintText: "password",
                ),
                textInputAction: TextInputAction.done,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).disabledColor),
                  onPressed: () async {
                    await loginForm(context, ref);
                  },
                  child: const Text("Login with Form")),
            ],
          ),
        ],
      ),
    );
  }
}

class UserInfoTexts extends ConsumerWidget {
  const UserInfoTexts(this.user, {super.key});

  final OidcUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userText = user?.userInfo.toString() ?? "no user";
    final accessToken = user?.token.accessToken ?? "no access token";

    final rolesText =
        ref.watch(currentUserRolesProvider)?.toString() ?? "no roles";
    return Column(
      children: [
        SelectableText(userText),
        const Divider(),
        SelectableText(rolesText),
        const Divider(),
        SelectableText(accessToken)
      ],
    );
  }
}
