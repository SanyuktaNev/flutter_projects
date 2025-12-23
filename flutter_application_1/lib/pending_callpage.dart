import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingCallPage extends StatefulWidget {
  const PendingCallPage({super.key});

  @override
  State<PendingCallPage> createState() => _PendingCallPageState();
}

class _PendingCallPageState extends State<PendingCallPage> {
  List<Map<String, dynamic>> pendingCalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPendingCalls();
  }

  Future<void> loadPendingCalls() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/calls.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        final allCalls = List<Map<String, dynamic>>.from(jsonData);

        final today = DateTime.now();
        final todayDateOnly =
            DateTime(today.year, today.month, today.day);

        final currentUserId =
            FirebaseAuth.instance.currentUser?.uid ?? "";

        pendingCalls = allCalls.where((call) {
          try {
            if (call['userId'] != currentUserId) return false;
            if (call['status'] != "scheduled") return false;

            final parts = call['callDate'].split('/');
            final callDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return callDate.isAfter(todayDateOnly) ||
                callDate.isAtSameMomentAs(todayDateOnly);
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : pendingCalls.isEmpty
            ? const Center(child: Text("No pending calls"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingCalls.length,
                itemBuilder: (_, index) {
                  final call = pendingCalls[index];
                  return Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.schedule, color: Colors.purple),
                      title: Text(call['name'] ?? ''),
                      subtitle: Text(
                        "${call['callDate']}  ${call['callTime']}",
                      ),
                    ),
                  );
                },
              );
  }
} 