import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/call_page.dart';

class PastCallPage extends StatefulWidget {
  const PastCallPage({super.key});

  @override
  State<PastCallPage> createState() => _PastCallPageState();
}

class _PastCallPageState extends State<PastCallPage> {
  List<Map<String, dynamic>> pastCalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPastCalls();
  }

 Future<void> loadPastCalls() async {
  setState(() => isLoading = true);

  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/calls.json");

  pastCalls = [];

  if (await file.exists()) {
    final content = await file.readAsString();
    if (content.isNotEmpty) {
      final List<dynamic> jsonData = json.decode(content);
      final List<Map<String, dynamic>> allCalls =
          List<Map<String, dynamic>>.from(jsonData);

      final DateTime today = DateTime.now();
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

      pastCalls = allCalls.where((call) {
        try {
          if (call['userId'] != currentUserId) return false;
          if (call['status'] != "completed") return false;

          final parts = call['callDate'].split('/');
          final callDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );

          return callDate.isBefore(today);
        } catch (e) {
          return false;
        }
      }).toList();

      // Sort descending by callDate
      pastCalls.sort((a, b) {
        final aParts = a['callDate'].split('/');
        final bParts = b['callDate'].split('/');
        final aDate = DateTime(int.parse(aParts[2]), int.parse(aParts[1]), int.parse(aParts[0]));
        final bDate = DateTime(int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));
        return bDate.compareTo(aDate);
      });
    }
  }

  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       appBar: AppBar(
  backgroundColor: Colors.purple,

  // ✅ Explicit white back button
  leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.white),
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CallPage()),
      (route) => false,
    );
  },
),


  title: const Text(
    "Past Calls",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),


        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pastCalls.isEmpty
                ? const Center(
                    child: Text(
                      "No past calls found",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
  onRefresh: loadPastCalls,
  child: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: pastCalls.length,
    itemBuilder: (context, index) {
      final call = pastCalls[index];
      Color outcomeColor;
      switch (call['callOutcome']) {
        case "Connected":
          outcomeColor = Colors.green;
          break;
        case "Busy":
          outcomeColor = Colors.orange;
          break;
        case "Not Answered":
          outcomeColor = Colors.red;
          break;
        default:
          outcomeColor = Colors.purple;
      }

      return Card(
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(Icons.call, color: outcomeColor, size: 40),
          title: Text(
            call['name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mobile: ${call['mobile'] ?? '-'}"),
              Text("Call Date: ${call['callDate'] ?? '-'}"),
              Text("Call Time: ${call['callTime'] ?? '-'}"),
              if (call['postComment'] != null && call['postComment'].toString().isNotEmpty)
                Text("Comment: ${call['postComment']}"),
              if (call['type'] != null) Text("Type: ${call['type']}"),
            ],
          ),
        ),
      );
    },
  ),
)

      ),
    );
  }
}
