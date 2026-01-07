import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
  title: const Text(
    "Schedule Visit",
    style: TextStyle(
      color: Colors.white, // ✅ Make title text white
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.purple,
  iconTheme: const IconThemeData(
    color: Colors.white, // ✅ Back button color
  ),
),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  buildTextField(nameController, "Person Name", Icons.person_outline),
                  buildTextField(mobileController, "Mobile Number", Icons.smartphone, keyboardType: TextInputType.number),
                  buildDatePicker(visitDateController, "Visit Date", Icons.calendar_today),
                  buildTimePicker(controller: visitTimeController, label: "Visit Time", icon: Icons.access_time),
                  buildTextField(postVisitCommentController, "Post Visit Comment", Icons.comment, maxLines: 3),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: saveScheduledVisit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Schedule Visit", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, decoration: inputDecoration(label, icon)),
    );
  }

  Widget buildDatePicker(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: inputDecoration(label, icon),
        onTap: () async {
          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
          if (picked != null) controller.text = "${picked.day}/${picked.month}/${picked.year}";
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
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.purple,   // header background
                  onPrimary: Colors.white,  // header text
                  onSurface: Colors.black,  // body text
                ),
                timePickerTheme: const TimePickerThemeData(
                  dialHandColor: Colors.purple,
                  dayPeriodColor: Colors.purple,      // AM/PM background
                  dayPeriodTextColor: Color.fromARGB(255, 0, 0, 0),   // AM/PM text
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null && mounted) {
          controller.text = picked.format(context);
        }
      },
    ),
  );
}


  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(prefixIcon: Icon(icon, color: Colors.purple), labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
  }

  Future<void> saveScheduledVisit() async {
    if (nameController.text.isEmpty || mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Mobile are required")));
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
      if (content.isNotEmpty) allVisits = List<Map<String, dynamic>>.from(json.decode(content));
    }

    allVisits.add(visitData);
    await file.writeAsString(json.encode(allVisits));

    if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Visit scheduled locally!")),
);

    _clearFields();
  }

  void _clearFields() {
    nameController.clear();
    mobileController.clear();
    visitDateController.clear();
    visitTimeController.clear();
    postVisitCommentController.clear();
  }
}
