import 'package:flutter/material.dart';
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language")),
      body: ListView(
        children: [
          ListTile(title: const Text("English"), onTap: () {}),
          ListTile(title: const Text("Hindi"), onTap: () {}),
          ListTile(title: const Text("Kannada"), onTap: () {}),
        ],
      ),
    );
  }
}
