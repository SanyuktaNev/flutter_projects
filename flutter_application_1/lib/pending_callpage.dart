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
        final todayDateOnly = DateTime(today.year, today.month, today.day);

        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

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

        // ✅ Sort pendingCalls by date and time
        pendingCalls.sort((a, b) {
          try {
            final aParts = a['callDate'].split('/');
            final bParts = b['callDate'].split('/');
            final aDate = DateTime(int.parse(aParts[2]), int.parse(aParts[1]), int.parse(aParts[0]));
            final bDate = DateTime(int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));

            // Compare date first
            int cmp = aDate.compareTo(bDate);
            if (cmp != 0) return cmp;

            // Then compare time if available
            if (a['callTime'] != null && b['callTime'] != null) {
              final aTime = a['callTime'].split(':');
              final bTime = b['callTime'].split(':');
              final aDateTime = DateTime(aDate.year, aDate.month, aDate.day, int.parse(aTime[0]), int.parse(aTime[1]));
              final bDateTime = DateTime(bDate.year, bDate.month, bDate.day, int.parse(bTime[0]), int.parse(bTime[1]));
              return aDateTime.compareTo(bDateTime);
            }
            return 0;
          } catch (_) {
            return 0;
          }
        });
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
            : RefreshIndicator(
                onRefresh: loadPendingCalls,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingCalls.length,
                  itemBuilder: (_, index) {
                    final call = pendingCalls[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.schedule, color: Colors.purple, size: 40),
                        title: Text(call['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${call['callDate']}"),
                            Text("Time: ${call['callTime']}"),
                            if (call['postComment'] != null && call['postComment'].isNotEmpty)
                              Text("Comment: ${call['postComment']}"),
                            if (call['type'] != null)
                              Text("Type: ${call['type']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
