// lib/ui/screens/auth/add_family_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matricare_444/ui/screens/home/home_page.dart';

class AddFamilyPage extends StatefulWidget {
  final String uid;
  const AddFamilyPage({super.key, required this.uid});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final TextEditingController _email = TextEditingController();
  final List<String> _family = [];

  Future<void> _addEmail() async {
    if (_email.text.trim().isEmpty) return;

    final email = _email.text.trim();
    _family.add(email);
    setState(() {});

    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      "family": _family,
    });

    _email.clear();
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(uid: widget.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.black,
        title: const Text("Add Family Access"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add family members who can view your health records.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            _buildInput(),
            const SizedBox(height: 15),

            _addBtn(),

            const SizedBox(height: 20),
            const Divider(),

            Expanded(
              child: ListView(
                children: _family.map((e) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.cyan),
                      title: Text(e, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                const Text("Finish Setup", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        labelText: "Family Email",
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.cyan.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _addBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text("Add", style: TextStyle(fontSize: 17)),
      ),
    );
  }
}
