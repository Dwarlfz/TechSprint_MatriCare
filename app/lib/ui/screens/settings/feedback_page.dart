import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _ctrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback'), backgroundColor: const Color(0xFF8A56AC)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _ctrl, maxLines: 6, decoration: const InputDecoration(labelText: 'Your feedback')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () async {
            await _db.collection('feedback').add({
              'uid': _auth.currentUser?.uid,
              'text': _ctrl.text,
              'createdAt': DateTime.now(),
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks!')));
            Navigator.pop(context);
          }, child: const Text('Send'))
        ]),
      ),
    );
  }
}
