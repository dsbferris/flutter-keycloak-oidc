import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:example/router.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar(context, ref),
      body: body(context, ref),
    );
  }

  AppBar appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Example"),
      actions: [
        IconButton(
            onPressed: () => AutoRouter.of(context).push(const SettingsRoute()),
            icon: const Icon(Icons.settings))
      ],
    );
  }

  Widget body(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(20),
          ElevatedButton(
            onPressed: () => context.router.push(LoginRoute(shallPop: false)),
            child: const Text("Login"),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () => context.router.push(const ProfileRoute()),
            child: const Text("Profile"),
          ),
        ],
      ),
    );
  }
}
