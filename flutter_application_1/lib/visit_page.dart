import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'today_visitpage.dart';
import 'pending_visitpage.dart';
import 'calendar_visitpage.dart';
import 'log_visitpage.dart';
import 'schedule_visitpage.dart';
import 'past_visitpage.dart';

class VisitPage extends StatefulWidget {
  const VisitPage({super.key});

  @override
  State<VisitPage> createState() => _VisitPageState();
}

class _VisitPageState extends State<VisitPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9C27B0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Back to previous screen
            },
          ),
          title: const Text(
            "Visit Tabs",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
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
        body: const TabBarView(
          children: [
            TodayVisitPage(),
            PendingVisitPage(),
            CalendarVisitPage(),
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          overlayOpacity: 0.3,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.location_on, color: Colors.white),
              backgroundColor: Colors.purple,
              label: 'Log Visit',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogVisitPage(),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.calendar_month, color: Colors.white),
              backgroundColor: Colors.purple,
              label: 'Schedule Visit',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleVisitPage(),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.history, color: Colors.white),
              backgroundColor: Colors.purple,
              label: 'Past Visit',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PastVisitPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
