import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  String? profileImageUrl;
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

      setState(() {
        firstnameController.text = data['firstname'] ?? '';
        lastnameController.text = data['lastname'] ?? '';
        emailController.text = data['email'] ?? '';
        genderController.text = data['gender'] ?? '';
        cityController.text = data['city'] ?? '';
        profileImageUrl = data['profileImage'];
        isLoading = false;
      });
    }
  }

  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(File(image.path));
    String downloadUrl = await ref.getDownloadURL();

    setState(() {
      profileImageUrl = downloadUrl;
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImage': downloadUrl,
    });
  }

  Future<void> saveProfileChanges() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'firstname': firstnameController.text.trim(),
      'lastname': lastnameController.text.trim(),
      'gender': genderController.text.trim(),
      'city': cityController.text.trim(),
    });

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
                  onTap: pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage(
                                'assets/default_avatar.png')
                            as ImageProvider,
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
                            backgroundColor:
                                const Color(0xFF9C27B0),
                            minimumSize:
                                const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18),
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
            borderSide:
                const BorderSide(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
