import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleVisitPage extends StatefulWidget {
  const ScheduleVisitPage({super.key});

  @override
  State<ScheduleVisitPage> createState() => _ScheduleVisitPageState();
}

class _ScheduleVisitPageState extends State<ScheduleVisitPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController visitDateController = TextEditingController();
  final TextEditingController visitTimeController = TextEditingController();
  final TextEditingController postVisitCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Schedule Visit",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    controller: visitDateController,
                    label: "Visit Date",
                    icon: Icons.calendar_today,
                  ),
                  buildTimePicker(
                    controller: visitTimeController,
                    label: "Visit Time",
                    icon: Icons.access_time,
                  ),
                  buildTextField(
                    controller: postVisitCommentController,
                    label: "Post Visit Comment",
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: saveScheduledVisit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Schedule Visit",
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
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            if (!mounted) return;
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
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary: Colors.purple, // header background
                    onPrimary: Colors.white, // header text
                    onSurface: Colors.black, // body text
                  ),
                  timePickerTheme: TimePickerThemeData(
                    hourMinuteTextColor: Colors.black, // hour/minute text
                    hourMinuteColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.purple; // selected hour/minute box
                      }
                      return Colors.transparent; // unselected
                    }),
                    dayPeriodTextColor: Colors.black, // AM/PM text
                    dayPeriodColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.purple; // selected AM/PM box
                      }
                      return Colors.transparent; // unselected
                    }),
                    dialHandColor: Colors.purple, // dial hand
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            if (!mounted) return;
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
  Future<void> saveScheduledVisit() async {
    if (nameController.text.trim().isEmpty || mobileController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Mobile are required")),
      );
      return;
    }

    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    final Map<String, dynamic> visitData = {
      "userId": userId,
      "status": "scheduled",
      "type": "schedule",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "visitDate": visitDateController.text.trim(),
      "visitTime": visitTimeController.text.trim(),
      "postComment": postVisitCommentController.text.trim(),
      "timestamp": DateTime.now().toIso8601String(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

    List<Map<String, dynamic>> allVisits = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        allVisits = List<Map<String, dynamic>>.from(jsonData);
      }
    }

    allVisits.add(visitData);
    await file.writeAsString(json.encode(allVisits));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Visit scheduled locally!")),
    );

    // Clear fields
    nameController.clear();
    mobileController.clear();
    visitDateController.clear();
    visitTimeController.clear();
    postVisitCommentController.clear();
  }
}
