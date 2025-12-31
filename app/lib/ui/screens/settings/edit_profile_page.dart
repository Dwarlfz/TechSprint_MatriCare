// lib/ui/screens/settings/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:matricare_444/core/services/database_service.dart';
import 'package:matricare_444/data/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfilePage extends StatefulWidget {
  // expects either a UserModel or just uid; we'll accept uid for simplicity
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final DatabaseService _db = DatabaseService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _doctorPhoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final ref = FirebaseDatabase.instance.ref('users/${widget.uid}');
    final snap = await ref.get();
    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      final user = UserModel.fromMap(data);

      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phoneNumber;
      _doctorPhoneCtrl.text = user.doctorPhno;
      _licenseCtrl.text = user.license;
      _ageCtrl.text = user.age;
      _dobCtrl.text = user.dateOfBirth;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _saving = true);

    final user = UserModel(
      uid: widget.uid,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      doctorPhno: _doctorPhoneCtrl.text.trim(),
      role: 'primary', // keep role default; you may expose role in UI later
      license: _licenseCtrl.text.trim(),
      deliveryDate: null,
      age: _ageCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim(),
    );

    try {
      await _db.saveUserProfile(widget.uid, user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF8A56AC),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: _doctorPhoneCtrl, decoration: const InputDecoration(labelText: 'Doctor phone')),
            const SizedBox(height: 12),
            TextField(controller: _licenseCtrl, decoration: const InputDecoration(labelText: 'License')),
            const SizedBox(height: 12),
            TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: 'Age')),
            const SizedBox(height: 12),
            TextField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
