import 'package:flutter/material.dart';

/// [LoadingScreen] is just a simple full-screen loading screen,
/// shown when [SharedPreferences] are being loaded
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
