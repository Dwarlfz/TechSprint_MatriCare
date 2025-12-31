import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Center")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("• How to use Vitals Dashboard"),
          SizedBox(height: 10),
          Text("• Troubleshooting login issues"),
          SizedBox(height: 10),
          Text("• Contact support: support@matricare.app"),
        ],
      ),
    );
  }
}
