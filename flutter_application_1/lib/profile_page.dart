import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  File? profileImageFile; // store local image
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;

      // If local image path exists, load it
      File? localImage;
      if (data['profileImagePath'] != null) {
        localImage = File(data['profileImagePath']);
        if (!localImage.existsSync()) {
          localImage = null; // file missing
        }
      }

      setState(() {
        firstnameController.text = data['firstname'] ?? '';
        lastnameController.text = data['lastname'] ?? '';
        emailController.text = data['email'] ?? '';
        genderController.text = data['gender'] ?? '';
        cityController.text = data['city'] ?? '';
        profileImageFile = localImage;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // Save image to app's local directory
    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await File(image.path)
        .copy('${appDir.path}/${FirebaseAuth.instance.currentUser!.uid}.png');

    setState(() {
      profileImageFile = savedImage;
    });

    // Save local path in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profileImagePath': savedImage.path});
  }

  Future<void> saveProfileChanges() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'firstname': firstnameController.text.trim(),
      'lastname': lastnameController.text.trim(),
      'gender': genderController.text.trim(),
      'city': cityController.text.trim(),
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: pickAndSaveImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!) as ImageProvider
                        : const AssetImage('assets/default_avatar.png'),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        buildField(
                            controller: firstnameController,
                            label: "First Name",
                            icon: Icons.person),
                        buildField(
                            controller: lastnameController,
                            label: "Last Name",
                            icon: Icons.person),
                        buildField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                            enabled: false),
                        buildField(
                            controller: genderController,
                            label: "Gender",
                            icon: Icons.wc),
                        buildField(
                            controller: cityController,
                            label: "City",
                            icon: Icons.location_city),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: saveProfileChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.purple),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
