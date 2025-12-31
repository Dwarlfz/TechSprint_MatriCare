import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool criticalAlerts = true;
  bool reminders = true;
  bool doctorUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Critical Health Alerts"),
            value: criticalAlerts,
            onChanged: (v) => setState(() => criticalAlerts = v),
          ),
          SwitchListTile(
            title: const Text("Daily Reminders"),
            value: reminders,
            onChanged: (v) => setState(() => reminders = v),
          ),
          SwitchListTile(
            title: const Text("Doctor Updates"),
            value: doctorUpdates,
            onChanged: (v) => setState(() => doctorUpdates = v),
          ),
        ],
      ),
    );
  }
}
