import 'package:auto_route/auto_route.dart';
import 'package:example/provider/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // leading: const AutoLeadingButton(),
        title: const Text("Settings"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ThemeModeTile(),
            AboutButton(),
          ],
        ),
      ),
    );
  }
}

class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(sharedUtilProvider.select((value) => value.themeMode));
    //final themeMode = ref.watch(themeModeProvider);
    return ListTile(
      leading: const Icon(Icons.sunny),
      title: const Text("Theme mode"),
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text("System"),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text("Dark"),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text("Light"),
          ),
        ],
        onChanged: (value) {
          if (value != null && value != themeMode) {
            ref.read(sharedUtilProvider).setThemeMode(value);
          }
        },
      ),
    );
  }
}

class AboutButton extends ConsumerWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.info),
      label: const Text("About"),
      onPressed: () => AutoRouter.of(context).pushWidget(
        opaque: false,
        fullscreenDialog: false,
        const AboutDialog(
          applicationIcon: FlutterLogo(),
          applicationVersion: "Version 0.0.1",
          applicationLegalese: "Lorem ipsum und die heilige Jungfrau Maria",
        ),
      ),
    );
  }
}
