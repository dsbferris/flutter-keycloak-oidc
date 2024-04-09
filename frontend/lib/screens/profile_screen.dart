import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/router.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("example"),
      actions: [
        IconButton(
            onPressed: () => AutoRouter.of(context).push(const SettingsRoute()),
            icon: const Icon(Icons.settings))
      ],
    );
  }

  Widget body(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello World!"),
        ],
      ),
    );
  }
}
