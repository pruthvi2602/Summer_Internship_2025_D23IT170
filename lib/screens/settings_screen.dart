import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tastybite/widgets/theme_provider.dart'; // import themeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 241, 247, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 241, 247, 1),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return SwitchListTile(
                title: const Text("Dark Mode"),
                value: mode == ThemeMode.dark,
                onChanged: (val) {
                  themeNotifier.value =
                      val ? ThemeMode.dark : ThemeMode.light;
                },
                secondary: const Icon(Iconsax.moon),
              );
            },
          ),
        ],
      ),
    );
  }
}
