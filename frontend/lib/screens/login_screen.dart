import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:example/provider/oidc_provider.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({this.shallPop = false, super.key});

  final bool shallPop;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool usernameIsEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    // final user = ref.watch(oidcProvider.select((value) => value.currentUser));
    final userText = user?.userInfo.toString();
    final token = user?.token;
    final accessToken = token?.accessToken;
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ElevatedButton(
            onPressed: () {
              ref.invalidate(oidcProvider);
            },
            child: const Text("Reset oidc manager (testing)"),
          ),
          const Gap(20),
          Visibility(
            visible: user == null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      const Text(
                          "Using the form is depracted. Please use Browser popup!"),
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
                          onPressed: () async {
                            await ref.read(oidcProvider.notifier).loginForm(
                                userNameController.text,
                                passwordController.text);
                            if (widget.shallPop && context.mounted) {
                              await context.router.maybePop();
                            }
                          },
                          child: const Text("Login with Form")),
                    ],
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(oidcProvider.notifier).loginPopup();
                      if (widget.shallPop && context.mounted) {
                        await context.router.maybePop();
                      }
                    },
                    child: const Text("Login Browser Popup"),
                  ),
                  const Gap(4),
                ],
              ),
            ),
          ),
          const Gap(20),
          Visibility(
            visible: user != null,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(oidcProvider.notifier).logout();
              },
              child: const Text("Logout"),
            ),
          ),
          const Gap(20),
          const Divider(),
          SelectableText(userText ?? "no user"),
          const Divider(),
          SelectableText(accessToken ?? "no access token")
        ],
      ),
    );
  }
}
