import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'login_screen.dart'; // 👈 Import Login Screen

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background white
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo above form
              Image.asset(
                "assets/BabyShopHub_LOGO.png",
                height: 120,
              ),
              const SizedBox(height: 30),

              // Gradient Form Box
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7EC8E3), // light blue
                      Color(0xFF397CA9), // deep blue
                      // Color(0xFFFBC7A9), // peach
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Name",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => name = v,
                        validator: (v) => v!.isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => email = v,
                        validator: (v) =>
                        v!.contains("@") ? null : "Enter valid email",
                      ),
                      const SizedBox(height: 15),

                      // Phone
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Phone",
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => phone = v,
                        validator: (v) => v!.isEmpty ? "Enter phone" : null,
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        onChanged: (v) => password = v,
                        validator: (v) =>
                        v!.length < 6 ? "Password too short" : null,
                      ),
                      const SizedBox(height: 20),

                      // Register Button
                      ElevatedButton(
                        onPressed: loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF397CA9),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                          color: Color(0xFF397CA9),
                        )
                            : const Text(
                          "Register",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Go to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
