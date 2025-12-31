import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matricare_444/data/models/user_model.dart';
import 'package:matricare_444/core/services/database_service.dart';
class ProfilePage extends StatefulWidget {
  final UserModel? user;   // <-- FIXED: nullable accepted
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();
  UserModel? user;
  late TextEditingController nameCtrl;
  late TextEditingController ageCtrl;
  late TextEditingController roleCtrl;
  late TextEditingController dobCtrl;
  late TextEditingController deliveryDateCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController doctorPhoneCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final u = widget.user; // local alias, nullable-safe

    nameCtrl = TextEditingController(text: u?.name ?? "");
    ageCtrl = TextEditingController(text: u?.age?.toString() ?? "");
    dobCtrl = TextEditingController(text: u?.dateOfBirth ?? "");
    roleCtrl=TextEditingController(text: u?.role??"");
    deliveryDateCtrl = TextEditingController(text: u?.deliveryDate ?? "");
    phoneCtrl = TextEditingController(text: u?.phoneNumber ?? "");
    doctorPhoneCtrl = TextEditingController(text: u?.doctorPhno ?? "");
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "name": nameCtrl.text.trim(),
      "age": int.tryParse(ageCtrl.text.trim()) ?? 0,
      "dob": dobCtrl.text.trim(),
      "role":roleCtrl.text.trim(),
      "deliveryDate": deliveryDateCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "doctorPhone": doctorPhoneCtrl.text.trim(),
    });

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Settings")),

      body: _saving
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Personal Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              _field("Name", nameCtrl),
              _field("Age", ageCtrl, number: true),
              _field("Date of Birth", dobCtrl),
              _field("role", roleCtrl),
              _field("Expected Delivery Date", deliveryDateCtrl),

              const SizedBox(height: 20),

              const Text("Contact Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              _field("Phone", phoneCtrl),
              _field("Doctor's Phone", doctorPhoneCtrl),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  final updatedUser = UserModel(
                    uid: user!.uid,
                    email: user!.email,
                    name: nameCtrl.text,
                    doctorPhno: user!.doctorPhno,
                    age: user!.age,
                    role: user!.role,
                    dateOfBirth: user!.dateOfBirth,
                    phoneNumber: user!.phoneNumber,
                    license: user!.license,
                  );

                  await _db.saveUserProfile(user!.uid, updatedUser);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile saved to cloud")),
                  );
                },
                child: Text("Save"),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }
}
