// lib/ui/screens/auth/language_selection_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'voice_guidance_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  final String uid;
  const LanguageSelectionPage({super.key, required this.uid});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selected;

  final List<Map<String, String>> languages = [
    {"code": "en", "name": "English"},
    {"code": "hi", "name": "Hindi"},
    {"code": "kn", "name": "Kannada"},
    {"code": "ta", "name": "Tamil"},
    {"code": "te", "name": "Telugu"},
    {"code": "ml", "name": "Malayalam"},
    {"code": "bn", "name": "Bengali"},
    {"code": "mr", "name": "Marathi"},
  ];

  Future<void> _save() async {
    if (_selected == null) return;

    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      "language": _selected,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", _selected!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceGuidancePage(uid: widget.uid),
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
        title: const Text("Choose Language"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your preferred language",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: languages.map((lang) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: RadioListTile(
                      title: Text(
                        lang["name"]!,
                        style: const TextStyle(fontSize: 17),
                      ),
                      activeColor: Colors.cyan,
                      value: lang["code"],
                      groupValue: _selected,
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _save,
                child: const Text("Continue", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
