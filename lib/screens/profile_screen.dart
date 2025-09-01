import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    DocumentSnapshot doc = await _db.collection("users").doc(user.uid).get();
    setState(() {
      nameController.text = doc["name"] ?? "";
      phoneController.text = doc["phone"] ?? "";
      emailController.text = doc["email"] ?? "";
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    await _db.collection("users").doc(user.uid).update({
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text, // ✅ fixed bug
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  Future<void> _logout() async {
    await _auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF397CA9),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueGrey.shade200,
              child: Text(
                nameController.text.isNotEmpty
                    ? nameController.text[0].toUpperCase()
                    : "U",
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Profile form card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: "Phone",
                          prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      readOnly: true, // ✅ usually email is fixed
                      decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF397CA9), // brand color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // pill style
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 4,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color(0xFF397CA9)),
              label: const Text(
                "Logout",
                style: TextStyle(
                    color: Color(0xFF397CA9), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF397CA9), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),


            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Order History"),
              onTap: () {
                Navigator.pushNamed(context, "/orders");
              },
            ),
          ],
        ),
      ),
    );
  }
}
