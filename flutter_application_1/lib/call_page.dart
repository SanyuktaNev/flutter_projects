import 'package:flutter/material.dart';
import 'package:flutter_application_1/log_callpage.dart';
import 'package:flutter_application_1/schedule_callpage.dart';
import 'package:flutter_application_1/past_callpage.dart';
import 'package:flutter_application_1/today_callpage.dart';
import 'package:flutter_application_1/pending_callpage.dart';
import 'package:flutter_application_1/calendar_callpage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/welcome_screen.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  
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
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    (route) => false, // removes all previous routes
  );
},

  ),
  title: const Text(
    "Call Tabs",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
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

    body: const TabBarView(
      children: [
        TodayCallPage(),
        PendingCallPage(),
        CalendarCallPage(),
      ],
    ),

    floatingActionButton: SpeedDial(
            icon: Icons.add,
            foregroundColor: Colors.white,
            activeIcon: Icons.close,
            backgroundColor: Colors.purple,
            overlayOpacity: 0.3,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.table_view, color: Colors.white),
                backgroundColor: Colors.purple,
                label: 'Log Call',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogCallPage()),
                    (route) => false,
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.apartment, color: Colors.white),
                backgroundColor: Colors.purple,
                label: 'Schedule Call',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScheduleCallPage(
                            )),
                  );
                },
              ),
              SpeedDialChild(
                child:
                    const Icon(Icons.menu_book_outlined, color: Colors.white),
                backgroundColor: Colors.purple,
                label: 'Past Call',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PastCallPage(
                            )),
                    (route) => false,
                  );
                },
              ),
              
            ],
          )
  ),
);

  }
}
