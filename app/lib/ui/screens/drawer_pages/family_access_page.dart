import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matricare_444/data/models/user_model.dart';

class FamilyAccessPage extends StatefulWidget {
  final UserModel? user;   // <-- FIXED: make it nullable
  const FamilyAccessPage({super.key, this.user});

  @override
  State<FamilyAccessPage> createState() => _FamilyAccessPageState();
}

class _FamilyAccessPageState extends State<FamilyAccessPage> {
  final TextEditingController familyEmailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _sendRequest() async {
    if (familyEmailCtrl.text.trim().isEmpty) return;

    if (widget.user?.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not loaded")),
      );
      return;
    }

    setState(() => _loading = true);

    final motherUid = widget.user!.uid!;
    final familyEmail = familyEmailCtrl.text.trim();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(motherUid)
        .collection("access_requests")
        .add({
      "email": familyEmail,
      "requested_at": DateTime.now().toIso8601String(),
      "status": "pending",
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request sent to ${widget.user?.name ?? 'mother'}")),
    );

    familyEmailCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Family Access (${u?.name ?? 'User'})"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Allow a family member to access your vitals, pregnancy updates and alerts.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: familyEmailCtrl,
              decoration: InputDecoration(
                labelText: "Family member's email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loading ? null : _sendRequest,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Send Access Request",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Divider(thickness: 1),
            const SizedBox(height: 20),

            const Text("Pending Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Expanded(
              child: u?.uid == null
                  ? const Center(child: Text("User not loaded"))
                  : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(u!.uid)
                    .collection("access_requests")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text("No requests yet."));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.email),
                        title: Text(d["email"] ?? ""),
                        subtitle: Text("Status: ${d["status"]}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
