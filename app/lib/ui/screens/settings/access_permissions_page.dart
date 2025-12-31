// lib/ui/screens/settings/access_permissions_page.dart
import 'package:flutter/material.dart';
import '../../../core/services/settings_service.dart';
import '../../../data/models/family_member.dart';

class AccessPermissionsPage extends StatefulWidget {
  const AccessPermissionsPage({super.key});

  @override
  State<AccessPermissionsPage> createState() => _AccessPermissionsPageState();
}

class _AccessPermissionsPageState extends State<AccessPermissionsPage> {
  final SettingsService _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Access'),
        backgroundColor: const Color(0xFF8A56AC),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8A56AC),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<FamilyMember>>(
        stream: _settings.familyAccessStream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snap.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text('No family members added yet', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final m = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?')),
                  title: Text(m.name.isNotEmpty ? m.name : '(No name)'),
                  subtitle: Text('${m.relation} • ${m.access}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(m),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    final name = TextEditingController();
    final relation = TextEditingController();
    String access = 'View Only';

    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 8),
                TextField(controller: relation, decoration: const InputDecoration(labelText: 'Relation')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: access,
                  items: const [
                    DropdownMenuItem(value: 'View Only', child: Text('View Only')),
                    DropdownMenuItem(value: 'Emergency Only', child: Text('Emergency Only')),
                    DropdownMenuItem(value: 'Full Access', child: Text('Full Access')),
                  ],
                  onChanged: (v) {
                    if (v != null) access = v;
                  },
                  decoration: const InputDecoration(labelText: 'Access Level'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final n = name.text.trim();
                final r = relation.text.trim();

                if (n.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
                  return;
                }

                try {
                  final m = FamilyMember(id: '', name: n, relation: r, access: access);
                  await _settings.addFamilyMember(m);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added')));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add member: $e')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(FamilyMember m) {
    final name = TextEditingController(text: m.name);
    final relation = TextEditingController(text: m.relation);
    String access = m.access;

    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Edit Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 8),
                TextField(controller: relation, decoration: const InputDecoration(labelText: 'Relation')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: access,
                  items: const [
                    DropdownMenuItem(value: 'View Only', child: Text('View Only')),
                    DropdownMenuItem(value: 'Emergency Only', child: Text('Emergency Only')),
                    DropdownMenuItem(value: 'Full Access', child: Text('Full Access')),
                  ],
                  onChanged: (v) {
                    if (v != null) access = v;
                  },
                  decoration: const InputDecoration(labelText: 'Access Level'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final n = name.text.trim();
                final r = relation.text.trim();

                if (n.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
                  return;
                }

                try {
                  final updated = FamilyMember(id: m.id, name: n, relation: r, access: access);
                  await _settings.updateFamilyMember(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member updated')));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(FamilyMember m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: Text('Are you sure you want to remove ${m.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _settings.deleteFamilyMember(m.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }
}
