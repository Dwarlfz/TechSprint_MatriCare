import 'package:flutter/material.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      body: SwitchListTile(
        title: const Text("Dark Mode"),
        value: dark,
        onChanged: (v) {
          setState(() => dark = v);
          // TODO: integrate with app-wide theme provider
        },
      ),
    );
  }
}
