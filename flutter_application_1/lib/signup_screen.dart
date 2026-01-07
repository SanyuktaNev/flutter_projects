import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();

  bool isLoading = false;

  String? selectedGender;
  bool showGenderOptions = false;

  String? selectedCity;

  Future<void> signupUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String? gender = selectedGender;
    String? city = selectedCity;

    if (email.isEmpty ||
        password.isEmpty ||
        firstname.isEmpty ||
        lastname.isEmpty ||
        gender == null ||
        city == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'gender': gender,
        'city': city,
      });

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   return PopScope(
  canPop: false, // disables default back behavior
  onPopInvokedWithResult: (bool didPop, Object? result) {
    if (didPop) return;
    // Navigate back to login
    Navigator.pushReplacementNamed(context, '/login');
  },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Create Account 👤",
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Join us and get started!",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),
                      Card(
                        elevation: 10,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              buildTextField(firstnameController, "First Name", Icons.person_outline),
                              const SizedBox(height: 20),
                              buildTextField(lastnameController, "Last Name", Icons.person_outline),
                              const SizedBox(height: 20),
                              buildTextField(emailController, "Email or Mobile no", Icons.person,
                                  keyboardType: TextInputType.text),
                              const SizedBox(height: 20),
                              buildTextField(passwordController, "Password", Icons.lock_outline,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              
                              // Gender field
                              GestureDetector(
                                onTap: () => setState(() => showGenderOptions = !showGenderOptions),
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person_outline, color: Colors.purple),
                                      labelText: selectedGender ?? "Select Gender",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (showGenderOptions) ...[
                                const SizedBox(height: 10),
                                Column(
                                  children: ["Male", "Female", "Other"].map((gender) {
                                    return ListTile(
                                      title: Text(gender),
                                      leading: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedGender = gender;
                                            showGenderOptions = false;
                                          });
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.purple, width: 2),
                                            color: selectedGender == gender ? Colors.purple : Colors.transparent,
                                          ),
                                          child: selectedGender == gender
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 20),

                              // City dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.location_city_outlined, color: Colors.purple),
                                  labelText: "Select City",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                initialValue: selectedCity,
                                items: ["Pune", "Mumbai", "Hyderabad", "Bangalore", "Delhi"]
                                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                                    .toList(),
                                onChanged: (val) => setState(() => selectedCity = val),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: isLoading ? null : signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: const Text(
                                  "Already a user? Sign in",
                                  style: TextStyle(
                                    color: Color.fromARGB(179, 5, 5, 5),
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
