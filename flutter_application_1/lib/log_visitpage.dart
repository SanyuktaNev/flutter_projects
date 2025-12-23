import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogVisitPage extends StatefulWidget {
  const LogVisitPage({super.key});

  @override
  State<LogVisitPage> createState() => _LogVisitPageState();
}

class _LogVisitPageState extends State<LogVisitPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController visitDateController = TextEditingController();
  final TextEditingController visitTimeController = TextEditingController();
  final TextEditingController postCommentController = TextEditingController();
  final TextEditingController nextVisitDateController = TextEditingController();
  final TextEditingController nextVisitTimeController = TextEditingController();
  final TextEditingController preVisitCommentController = TextEditingController();

  String? visitOutcome;
  bool scheduleNextVisit = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9C27B0),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Log Visit",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                  DropdownButtonFormField<String>(
                    decoration: inputDecoration("Visit Outcome", Icons.check_circle),
                    initialValue: visitOutcome,
                    items: const [
                      DropdownMenuItem(value: "Connected", child: Text("Connected")),
                      DropdownMenuItem(value: "Busy", child: Text("Busy")),
                      DropdownMenuItem(value: "Not Answered", child: Text("Not Answered")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        visitOutcome = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  buildDatePicker(
                    controller: visitDateController,
                    label: "Visit Date",
                    icon: Icons.calendar_today,
                    lastDate: DateTime.now(),
                  ),
                  buildTimePicker(
                    controller: visitTimeController,
                    label: "Visit Time",
                    icon: Icons.access_time,
                  ),
                  buildTextField(
                    controller: postCommentController,
                    label: "Post Visit Comment",
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Schedule next visit?"),
                    value: scheduleNextVisit,
                    activeThumbColor: Colors.purple,
                    activeTrackColor: Colors.purple.shade200,
                    onChanged: (value) {
                      setState(() {
                        scheduleNextVisit = value;
                      });
                    },
                  ),
                  if (scheduleNextVisit) ...[
                    buildDatePicker(
                      controller: nextVisitDateController,
                      label: "Next Visit Date",
                      icon: Icons.calendar_month,
                      firstDate: DateTime.now(),
                    ),
                    buildTimePicker(
                      controller: nextVisitTimeController,
                      label: "Next Visit Time",
                      icon: Icons.access_time,
                    ),
                    buildTextField(
                      controller: preVisitCommentController,
                      label: "Pre Visit Comment",
                      icon: Icons.note,
                      maxLines: 2,
                    ),
                  ],
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: saveVisitLocally,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Visit",
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
    DateTime? firstDate,
    DateTime? lastDate,
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
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
          );
          if (picked != null) {
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
                  colorScheme: const ColorScheme.light(
                    primary: Colors.purple,    // header background
                    onPrimary: Colors.white,   // header text
                    onSurface: Colors.black,   // body text
                  ),
                  timePickerTheme: TimePickerThemeData(
                    hourMinuteTextColor: Colors.black,
                    hourMinuteColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.purple; // selected hour/minute box
                      }
                      return Colors.transparent;
                    }),
                    dayPeriodTextColor: Colors.black,
                    dayPeriodColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.purple; // selected AM/PM box
                      }
                      return Colors.transparent;
                    }),
                    dialHandColor: Colors.purple,
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

  Future<void> saveVisitLocally() async {
    if (nameController.text.trim().isEmpty || mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Mobile are required")),
      );
      return;
    }

    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final Map<String, dynamic> callData = {
      "userId": userId,
      "status": "completed",
      "type": "log",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "visitOutcome": visitOutcome,
      "visitDate": visitDateController.text.trim(),
      "visitTime": visitTimeController.text.trim(),
      "postComment": postCommentController.text.trim(),
      "scheduleNextVisit": scheduleNextVisit,
      "nextVisitDate":
          scheduleNextVisit ? nextVisitDateController.text.trim() : null,
      "nextVisitTime":
          scheduleNextVisit ? nextVisitTimeController.text.trim() : null,
      "preVisitComment":
          scheduleNextVisit ? preVisitCommentController.text.trim() : null,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Visit saved locally!")),
    );

    nameController.clear();
    mobileController.clear();
    visitDateController.clear();
    visitTimeController.clear();
    postCommentController.clear();
    nextVisitDateController.clear();
    nextVisitTimeController.clear();
    preVisitCommentController.clear();
    setState(() {
      visitOutcome = null;
      scheduleNextVisit = false;
    });
  }
}
