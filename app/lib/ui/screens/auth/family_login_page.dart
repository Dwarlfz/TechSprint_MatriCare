import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matricare_444/ui/screens/home/family_home_page.dart';

class FamilyLoginPage extends StatefulWidget {
  final String token;
  const FamilyLoginPage({super.key, required this.token});

  @override
  State<FamilyLoginPage> createState() => _FamilyLoginPageState();
}

class _FamilyLoginPageState extends State<FamilyLoginPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _login();
  }

  Future<void> _login() async {
    try {
      UserCredential cred =
      await FirebaseAuth.instance.signInWithCustomToken(widget.token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FamilyHomePage(uid: cred.user!.uid),
        ),
      );

    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _loading ? CircularProgressIndicator() : const Text("Invalid token")),
    );
  }
}
