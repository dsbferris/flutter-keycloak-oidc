import 'package:auto_route/auto_route.dart';
import 'package:example/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protectedApiResponse = ref.watch(protectedApiProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("This is a protected route!"),
            protectedApiResponse.isLoading
                ? const CircularProgressIndicator.adaptive()
                : Text(protectedApiResponse.hasError
                    ? protectedApiResponse.error.toString()
                    : protectedApiResponse.hasValue
                        ? protectedApiResponse.value ?? "value null"
                        : "no error, no value"),
          ],
        ),
      ),
    );
  }
}
