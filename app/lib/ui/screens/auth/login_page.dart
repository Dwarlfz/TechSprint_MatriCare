import 'package:flutter/material.dart';
import 'package:matricare_444/core/services/auth_service.dart';
import 'package:matricare_444/data/models/user_model.dart';
import 'package:matricare_444/ui/screens/auth/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matricare_444/core/routes/app_routes.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _loading = false;
  UserModel? user;
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final userCred = await _auth.signInAndFetchUser(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (userCred != null) {
        // userCred.uid is guaranteed NOT null now
        Navigator.pushReplacementNamed(
          context,
          "/home",
          arguments: userCred.uid,
        );
      } else {
        _showSnack('User data not found. Please register.');
      }
    } on Exception catch (e) {
      _showSnack('Login failed: ${_errorMessage(e)}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorMessage(Object e) {
    final s = e.toString();
    if (s.contains('wrong-password')) return 'Wrong password';
    if (s.contains('user-not-found')) return 'No user found';
    return s;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login', style: TextStyle(color: Colors.black),),backgroundColor: Colors.cyan,),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.cyanAccent.shade100,
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('lib/assets/images/logo_2.jpg',
                        width: 120, height: 120),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Password must be 6+ chars';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Login'),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text("Don't have an account? Sign up"),
                    ),

                    // ---------------------------
                    // Login as fsmily
                    // ---------------------------
                    TextButton(
                      onPressed: () {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No user found")),
                          );
                          return;
                        }

                        Navigator.pushNamed(
                          context,
                          AppRoutes.familyLoginPage,
                          arguments: user!.uid,
                        );
                      },
                      child: const Text('Login as Family member'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
