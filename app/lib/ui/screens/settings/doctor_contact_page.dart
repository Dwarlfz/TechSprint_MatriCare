import 'package:flutter/material.dart';
import 'package:matricare_444/core/services/database_service.dart';
import 'package:matricare_444/data/models/user_model.dart';

class DoctorContactPage extends StatefulWidget {
  final String uid; // pass user uid

  const DoctorContactPage({super.key, required this.uid});

  @override
  State<DoctorContactPage> createState() => _DoctorContactPageState();
}

class _DoctorContactPageState extends State<DoctorContactPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _specCtrl = TextEditingController();

  final DatabaseService _db = DatabaseService();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final ref = _db.vitalsRef(widget.uid); // Using users/$uid; we could add doctors node
    final snap = await ref.child('doctors').get();
    if (snap.exists && snap.value != null) {
      final doctorsMap = Map<String, dynamic>.from(snap.value as Map);
      // take first doctor if exists
      final firstDoctor = doctorsMap.entries.first.value as Map;
      _nameCtrl.text = firstDoctor['name'] ?? '';
      _phoneCtrl.text = firstDoctor['phone'] ?? '';
      _clinicCtrl.text = firstDoctor['clinic'] ?? '';
      _specCtrl.text = firstDoctor['specialization'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _saveDoctor() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final doctorData = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'clinic': _clinicCtrl.text.trim(),
      'specialization': _specCtrl.text.trim(),
    };

    try {
      await _db.addDoctor(widget.uid, doctorData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor saved')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Contact'), backgroundColor: const Color(0xFF8A56AC)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _specCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
            const SizedBox(height: 12),
            TextField(controller: _clinicCtrl, decoration: const InputDecoration(labelText: 'Clinic')),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveDoctor,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Doctor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
