import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  String name = "", email = "", phone = "", password = "";
  bool loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await _auth.register(name, email, phone, password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
              onChanged: (v) => name = v,
              validator: (v) => v!.isEmpty ? "Enter name" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Email"),
              onChanged: (v) => email = v,
              validator: (v) => v!.contains("@") ? null : "Enter valid email",
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Phone"),
              onChanged: (v) => phone = v,
              validator: (v) => v!.isEmpty ? "Enter phone" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (v) => password = v,
              validator: (v) => v!.length < 6 ? "Password too short" : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _register,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
          ]),
        ),
      ),
    );
  }
}
