import 'package:flutter/material.dart';
import 'package:matricare_444/core/services/auth_service.dart';
import 'package:matricare_444/ui/screens/auth/language_selection_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _doctorPhone = TextEditingController();
  final TextEditingController _license = TextEditingController();

  bool _loading = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dob.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = await _auth.register(
        email: _email.text.trim(),
        password: _pass.text.trim(),
        name: _name.text.trim(),
        age: "", // ❗ removed age entirely
        role: _role.text.trim(),
        dateOfBirth: _dob.text.trim(),
        phoneNumber: _phone.text.trim(),
        doctorPhno: _doctorPhone.text.trim(),
        license: _license.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LanguageSelectionPage(uid: user.uid),
          ),
        );
      } else {
        _show('Registration failed');
      }
    } catch (e) {
      _show('Sign up error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    _role.dispose();
    _dob.dispose();
    _phone.dispose();
    _doctorPhone.dispose();
    _license.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('lib/assets/images/logo_2.jpg', width: 110, height: 110),
              const SizedBox(height: 12),

              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Password 6+ chars' : null,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),

              const SizedBox(height: 8),

              // 🎉 DOB with Date Picker
              TextFormField(
                controller: _dob,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: _pickDate,
                validator: (v) => (v == null || v.isEmpty) ? "Select your date of birth" : null,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _doctorPhone,
                decoration: const InputDecoration(labelText: 'Doctor phone'),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _license,
                decoration: const InputDecoration(labelText: 'License number'),
              ),

              const SizedBox(height: 16),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
