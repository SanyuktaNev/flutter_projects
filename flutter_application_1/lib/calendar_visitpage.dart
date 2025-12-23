import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarVisitPage extends StatefulWidget {
  const CalendarVisitPage({super.key});

  @override
  State<CalendarVisitPage> createState() => _CalendarVisitPageState();
}

class _CalendarVisitPageState extends State<CalendarVisitPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> filteredVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVisits();
  }

  Future<void> loadVisits() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        final allVisits = List<Map<String, dynamic>>.from(jsonData);

        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        filteredVisits = allVisits.where((visit) {
          try {
            if (visit['userId'] != currentUserId) return false;

            final parts = visit['visitDate'].split('/');
            final visitDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return visitDate.year == selectedDate.year &&
                visitDate.month == selectedDate.month &&
                visitDate.day == selectedDate.day;
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
      await loadVisits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: pickDate,
          icon: const Icon(Icons.calendar_month),
          label: const Text("Pick Date", style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredVisits.isEmpty
                  ? const Center(child: Text("No visits found"))
                  : ListView.builder(
                      itemCount: filteredVisits.length,
                      itemBuilder: (_, index) {
                        final visit = filteredVisits[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              visit['status'] == "scheduled"
                                  ? Icons.schedule
                                  : Icons.location_on,
                              color: Colors.purple,
                            ),
                            title: Text(visit['name'] ?? ''),
                            subtitle: Text(
                              "${visit['visitTime']} (${visit['status']})",
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
