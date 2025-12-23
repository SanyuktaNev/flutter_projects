import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/expandable_fab.dart';

import 'package:flutter_application_1/log_visitpage.dart';
import 'package:flutter_application_1/schedule_visitpage.dart';
import 'package:flutter_application_1/past_visitpage.dart';

import 'package:flutter_application_1/today_visitpage.dart';
import 'package:flutter_application_1/pending_visitpage.dart';
import 'package:flutter_application_1/calendar_visitpage.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9C27B0),
          title: const Text(
            "Visit Tabs",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.today), text: "Today's Visit"),
              Tab(icon: Icon(Icons.pending_actions), text: "Pending Visit"),
              Tab(icon: Icon(Icons.calendar_month), text: "Calendar Visit"),
            ],
          ),
        ),

        // ✅ EXACT SAME LOGIC AS CALL PAGE
        body: const TabBarView(
          children: [
            TodayVisitPage(),
            PendingVisitPage(),
            CalendarVisitPage(),
          ],
        ),

        // ✅ EXACT SAME EXPANDABLE FAB PATTERN
        floatingActionButton: ExpandableFab(
          distance: 100,
          children: [
            ActionButton(
              icon: const Icon(Icons.location_on),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LogVisitPage(),
                ),
              ),
            ),
            ActionButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScheduleVisitPage(),
                ),
              ),
            ),
            ActionButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PastVisitPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
