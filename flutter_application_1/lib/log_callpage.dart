import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class LogCallPage extends StatefulWidget {
  const LogCallPage({super.key});

  @override
  State<LogCallPage> createState() => _LogCallPageState();
}

class _LogCallPageState extends State<LogCallPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController callDateController = TextEditingController();
  final TextEditingController callTimeController = TextEditingController();
  final TextEditingController postCommentController = TextEditingController();
  final TextEditingController nextCallDateController = TextEditingController();
  final TextEditingController nextCallTimeController = TextEditingController();
  final TextEditingController preCallCommentController = TextEditingController();

  String? callOutcome;
  bool scheduleNextCall = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        iconTheme: const IconThemeData(
         color: Colors.white, // ✅ Back button color
          ),
          title: const Text(
            "Log Call",
            style: TextStyle(
            color: Colors.white, // ✅ Title text color
            fontWeight: FontWeight.bold,
    ),
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
                    decoration: inputDecoration("Call Outcome", Icons.check_circle),
                    initialValue: callOutcome,
                    items: const [
                      DropdownMenuItem(value: "Connected", child: Text("Connected")),
                      DropdownMenuItem(value: "Busy", child: Text("Busy")),
                      DropdownMenuItem(value: "Not Answered", child: Text("Not Answered")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        callOutcome = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  buildDatePicker(
                    controller: callDateController,
                    label: "Call Date",
                    icon: Icons.calendar_today,
                    lastDate: DateTime.now(),
                  ),
                  buildTimePicker(
                    controller: callTimeController,
                    label: "Call Time",
                    icon: Icons.access_time,
                  ),
                  buildTextField(
                    controller: postCommentController,
                    label: "Post Call Comment",
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Schedule next call?"),
                    value: scheduleNextCall,
                    activeThumbColor: Colors.purple,
                    activeTrackColor: Colors.purple.shade200,

                    onChanged: (value) {
                      setState(() {
                        scheduleNextCall = value;
                      });
                    },
                  ),
                  if (scheduleNextCall) ...[
                    buildDatePicker(
                      controller: nextCallDateController,
                      label: "Next Call Date",
                      icon: Icons.calendar_month,
                      firstDate: DateTime.now(),
                    ),
                    buildTimePicker(
                      controller: nextCallTimeController,
                      label: "Next Call Time",
                      icon: Icons.access_time,
                    ),
                    buildTextField(
                      controller: preCallCommentController,
                      label: "Pre Call Comment",
                      icon: Icons.note,
                      maxLines: 2,
                    ),
                  ],
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: saveCallLocally,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Call",
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
          TimeOfDay? picked =
              await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
  Future<void> saveCallLocally() async {
    if (nameController.text.trim().isEmpty || mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Mobile are required")),
      );
      return;
    }

    final Map<String, dynamic> callData = {
      "type": "log",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "callOutcome": callOutcome,
      "callDate": callDateController.text.trim(),
      "callTime": callTimeController.text.trim(),
      "postComment": postCommentController.text.trim(),
      "scheduleNextCall": scheduleNextCall,
      "nextCallDate": scheduleNextCall ? nextCallDateController.text.trim() : null,
      "nextCallTime": scheduleNextCall ? nextCallTimeController.text.trim() : null,
      "preCallComment": scheduleNextCall ? preCallCommentController.text.trim() : null,
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

    if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Call saved locally!")),
);

    // Clear all fields
    nameController.clear();
    mobileController.clear();
    callDateController.clear();
    callTimeController.clear();
    postCommentController.clear();
    nextCallDateController.clear();
    nextCallTimeController.clear();
    preCallCommentController.clear();
    setState(() {
      callOutcome = null;
      scheduleNextCall = false;
    });
  }
}
