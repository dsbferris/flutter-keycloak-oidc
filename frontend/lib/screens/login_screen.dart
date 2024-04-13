import 'package:auto_route/auto_route.dart';
import 'package:example/provider/oidc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:oidc/oidc.dart';

@RoutePage<bool>()
class LoginScreen extends ConsumerWidget {
  const LoginScreen({this.shallPop = false, super.key});

  final bool shallPop;

  void loginPopup(BuildContext context, WidgetRef ref) async {
    if (context.mounted) context.loaderOverlay.show();
    final result = await MyManager(ref).loginPopup();

    if (context.mounted) context.loaderOverlay.hide();

    if (shallPop && context.mounted) {
      await AutoRouter.of(context).maybePop(result.isLoggedIn);
    }
  }

  void logout(BuildContext context, WidgetRef ref) async {
    if (context.mounted) context.loaderOverlay.show();
    await MyManager(ref).logout();
    if (context.mounted) context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Visibility(
                visible: !user.isLoggedIn,
                child: Column(
                  children: [
                    UserLoginForm(shallPop),
                    FilledButton(
                      onPressed: () => loginPopup(context, ref),
                      child: const Text("Login Browser Popup"),
                    ),
                  ],
                )),
            const Gap(4),
            Visibility(
              visible: user.isLoggedIn,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await MyManager(ref).refreshToken();
                    },
                    child: const Text("Refresh Token manually"),
                  ),
                  const Gap(4),
                  ElevatedButton(
                    onPressed: () async {
                      await MyManager(ref).logout();
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

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginForm(BuildContext context, WidgetRef ref) async {
    final result = await MyManager(ref).loginForm(
        username: userNameController.text, password: passwordController.text);
    if (widget.shallPop && context.mounted) {
      await AutoRouter.of(context).maybePop(result.isLoggedIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contextColorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Column(
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
          const Gap(4),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: contextColorScheme.errorContainer,
              foregroundColor: contextColorScheme.onErrorContainer,
            ),
            onPressed: () async {
              await loginForm(context, ref);
            },
            child: const Text("Login with Form"),
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

    final rolesText = user?.roles?.toString() ?? "no roles";
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
