import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  File? profileImageFile;
  bool isLoading = true;
  bool isSaving = false;
  bool isImageUploading = false;

  String? actualUserId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
  setState(() => isLoading = true);

  if (widget.userId != null && widget.userId!.isNotEmpty) {
    actualUserId = widget.userId;
  } else {
    final prefs = await SharedPreferences.getInstance();

    // ✅ FIX: use stored UID
    final uid = prefs.getInt("uid");
    actualUserId = uid?.toString();
  }

  if (actualUserId != null && actualUserId!.isNotEmpty) {
    await fetchUserData();
  } else {
    setState(() => isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User ID not found. Please login again.")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}


  Future<void> fetchUserData() async {
    if (actualUserId == null || actualUserId!.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(actualUserId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        File? localImage;
        
        if (data['profileImagePath'] != null) {
          localImage = File(data['profileImagePath']);
          if (!localImage.existsSync()) localImage = null;
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
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User profile not found")),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e")),
        );
      }
    }
  }

  Future<void> pickAndSaveImage() async {
    if (actualUserId == null || actualUserId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not available")),
      );
      return;
    }

    setState(() => isImageUploading = true);

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) {
      setState(() => isImageUploading = false);
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await File(image.path)
        .copy('${appDir.path}/$actualUserId.png');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(actualUserId)
        .update({'profileImagePath': savedImage.path});

    setState(() {
      profileImageFile = savedImage;
      isImageUploading = false;
    });
  }

  Future<void> saveProfileChanges() async {
    if (actualUserId == null || actualUserId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not available")),
      );
      return;
    }

    if (isSaving) return;
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(actualUserId)
          .update({
        'firstname': firstnameController.text.trim(),
        'lastname': lastnameController.text.trim(),
        'gender': genderController.text.trim(),
        'city': cityController.text.trim(),
      });

      setState(() => isSaving = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      setState(() => isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: profileImageFile != null
                            ? FileImage(profileImageFile!)
                            : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      ),
                      if (isImageUploading)
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                    ],
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
                          child: isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
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