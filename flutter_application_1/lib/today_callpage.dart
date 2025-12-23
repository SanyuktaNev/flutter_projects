import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayCallPage extends StatefulWidget {
  const TodayCallPage({super.key});

  @override
  State<TodayCallPage> createState() => _TodayCallPageState();
}

class _TodayCallPageState extends State<TodayCallPage> {
  List<Map<String, dynamic>> todayCalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayCalls();
  }

  Future<void> loadTodayCalls() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/calls.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        final allCalls = List<Map<String, dynamic>>.from(jsonData);

        final today = DateTime.now();
        final currentUserId =
            FirebaseAuth.instance.currentUser?.uid ?? "";

        todayCalls = allCalls.where((call) {
          try {
            if (call['userId'] != currentUserId) return false;
            if (call['status'] != "completed") return false;

            final parts = call['callDate'].split('/');
            final callDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return callDate.year == today.year &&
                callDate.month == today.month &&
                callDate.day == today.day;
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
        : todayCalls.isEmpty
            ? const Center(child: Text("No calls for today"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todayCalls.length,
                itemBuilder: (_, index) {
                  final call = todayCalls[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.call, color: Colors.purple),
                      title: Text(call['name'] ?? ''),
                      subtitle: Text(
                        "${call['mobile']}\n${call['callTime']}",
                      ),
                    ),
                  );
                },
              );
  }
}
