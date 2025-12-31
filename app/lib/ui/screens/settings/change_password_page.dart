import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), backgroundColor: const Color(0xFF8A56AC)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 20),
          TextField(controller: _pass1, decoration: const InputDecoration(labelText: 'New password'), obscureText: true),
          const SizedBox(height: 20),
          TextField(controller: _pass2, decoration: const InputDecoration(labelText: 'Confirm password'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : () async {
              if (_pass1.text != _pass2.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                return;
              }
              setState(()=>_loading=true);
              try {
                await _auth.changePassword(_pass1.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
              } finally { setState(()=>_loading=false); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A56AC)),
            child: _loading ? const CircularProgressIndicator() : const Text('Change',style: TextStyle(color: Colors.white),),
          )
        ]),
      ),
    );
  }
}
