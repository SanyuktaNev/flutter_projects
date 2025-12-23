import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarCallPage extends StatefulWidget {
  const CalendarCallPage({super.key});

  @override
  State<CalendarCallPage> createState() => _CalendarCallPageState();
}

class _CalendarCallPageState extends State<CalendarCallPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> filteredCalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCalls();
  }

  Future<void> loadCalls() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/calls.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        final allCalls = List<Map<String, dynamic>>.from(jsonData);

        final currentUserId =
            FirebaseAuth.instance.currentUser?.uid ?? "";

        filteredCalls = allCalls.where((call) {
          try {
            if (call['userId'] != currentUserId) return false;

            final parts = call['callDate'].split('/');
            final callDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return callDate.year == selectedDate.year &&
                callDate.month == selectedDate.month &&
                callDate.day == selectedDate.day;
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      await loadCalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: pickDate,
          icon: const Icon(Icons.calendar_month),
          label: const Text("Pick Date"),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredCalls.isEmpty
                  ? const Center(child: Text("No calls found"))
                  : ListView.builder(
                      itemCount: filteredCalls.length,
                      itemBuilder: (_, index) {
                        final call = filteredCalls[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              call['status'] == "scheduled"
                                  ? Icons.schedule
                                  : Icons.call,
                              color: Colors.purple,
                            ),
                            title: Text(call['name'] ?? ''),
                            subtitle: Text(
                              "${call['callTime']} (${call['status']})",
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
