import 'package:auto_route/auto_route.dart';
import 'package:example/api/api.dart';
import 'package:example/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> pushSettings(BuildContext context, WidgetRef ref) async {
    await AutoRouter.of(context).push(const SettingsRoute());
  }

  Future<void> pushLogin(BuildContext context, WidgetRef ref) async {
    await AutoRouter.of(context).push(LoginRoute(shallPop: false));
  }

  Future<void> pushProfile(BuildContext context, WidgetRef ref) async {
    await AutoRouter.of(context).push(const ProfileRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicResponse = ref.watch(publicApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
        actions: [
          IconButton(
            onPressed: () async => await pushSettings(context, ref),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            publicResponse.isLoading
                ? const CircularProgressIndicator.adaptive()
                : Text(publicResponse.hasError
                    ? publicResponse.error.toString()
                    : publicResponse.hasValue
                        ? publicResponse.value ?? "value null"
                        : "no error, no value"),
            const Gap(20),
            ElevatedButton(
              onPressed: () async => await pushLogin(context, ref),
              child: const Text("Login"),
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: () async => await pushProfile(context, ref),
              child: const Text("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
