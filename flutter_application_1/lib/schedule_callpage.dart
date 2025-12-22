import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleCallPage extends StatefulWidget {
  const ScheduleCallPage({super.key});

  @override
  State<ScheduleCallPage> createState() => _ScheduleCallPageState();
}

class _ScheduleCallPageState extends State<ScheduleCallPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController callDateController = TextEditingController();
  final TextEditingController callTimeController = TextEditingController();
  final TextEditingController postCallCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          iconTheme: const IconThemeData(
            color: Colors.white, // ✅ Back button color
          ),
          title: const Text(
            "Schedule Call",
            style: TextStyle(
              color: Colors.white, // ✅ Title color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 10,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  buildTextField(
                    controller: nameController,
                    label: "Person Name",
                    icon: Icons.person_outline,
                  ),
                  buildTextField(
                    controller: mobileController,
                    label: "Mobile Number",
                    icon: Icons.smartphone,
                    keyboardType: TextInputType.number,
                  ),
                  buildDatePicker(
                    controller: callDateController,
                    label: "Call Date",
                    icon: Icons.calendar_today,
                  ),
                  buildTimePicker(
                    controller: callTimeController,
                    label: "Call Time",
                    icon: Icons.access_time,
                  ),
                  buildTextField(
                    controller: postCallCommentController,
                    label: "Post Call Comment",
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: saveScheduledCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Schedule Call",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: inputDecoration(label, icon),
      ),
    );
  }

  Widget buildDatePicker({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: inputDecoration(label, icon),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(), // future dates only
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            if (!mounted) return; // ✅ check mounted
            controller.text = "${picked.day}/${picked.month}/${picked.year}";
          }
        },
      ),
    );
  }

  Widget buildTimePicker({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: inputDecoration(label, icon),
        onTap: () async {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            if (!mounted) return; // ✅ check mounted
            controller.text = picked.format(context);
          }
        },
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.purple),
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// ---------------- LOCAL STORAGE ----------------
  Future<void> saveScheduledCall() async {
    if (nameController.text.trim().isEmpty || mobileController.text.trim().isEmpty) {
      if (!mounted) return; // ✅ check mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Mobile are required")),
      );
      return;
    }
    
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    final Map<String, dynamic> callData = {
      "userId": userId,
      "type": "schedule",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "callDate": callDateController.text.trim(),
      "callTime": callTimeController.text.trim(),
      "postComment": postCallCommentController.text.trim(),
      "timestamp": DateTime.now().toIso8601String(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/calls.json");

    List<Map<String, dynamic>> allCalls = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        allCalls = List<Map<String, dynamic>>.from(jsonData);
      }
    }

    allCalls.add(callData);
    await file.writeAsString(json.encode(allCalls));

    if (!mounted) return; // ✅ mounted check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Call scheduled locally!")),
    );

    // Clear fields
    nameController.clear();
    mobileController.clear();
    callDateController.clear();
    callTimeController.clear();
    postCallCommentController.clear();
  }
}
