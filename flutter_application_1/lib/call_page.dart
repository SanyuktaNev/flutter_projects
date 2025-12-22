import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/expandable_fab.dart';
import 'package:flutter_application_1/log_callpage.dart';
import 'package:flutter_application_1/schedule_callpage.dart';
import 'package:flutter_application_1/past_callpage.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        title: const Text(
        "Call Tabs",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
        color: Colors.white, // ✅ Back button color
      ),
  bottom: const TabBar(
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    tabs: [
      Tab(icon: Icon(Icons.call_made), text: "Today's Call"),
      Tab(icon: Icon(Icons.pending_actions), text: "Pending Call"),
      Tab(icon: Icon(Icons.calendar_month), text: "Calendar Call"),
    ],
  ),
),

        body: TabBarView(
          children: [
            Center(child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0))),
            Center(child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0))),
            Center(child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0))),
          ],
        ),
        floatingActionButton: ExpandableFab(
          distance: 100,
          children: [
            ActionButton(
              icon: const Icon(Icons.call),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogCallPage()),
              ),
            ),
            ActionButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScheduleCallPage()),
              ),
            ),
            ActionButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PastCallPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
