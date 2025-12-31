// lib/ui/screens/auth/voice_guidance_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_family_page.dart';

class VoiceGuidancePage extends StatelessWidget {
  final String uid;
  const VoiceGuidancePage({super.key, required this.uid});

  Future<void> _set(BuildContext context, bool value) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      "voice_guidance": value,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddFamilyPage(uid: uid),
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
        title: const Text("Voice Guidance"),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.volume_up, size: 70, color: Colors.cyan),
              const SizedBox(height: 20),
              const Text(
                "Do you want voice guidance?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              _optionBtn(context, "Yes, enable it", true),
              const SizedBox(height: 10),
              _optionBtn(context, "No, continue", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionBtn(BuildContext context, String text, bool value) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _set(context, value),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
