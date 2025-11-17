import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TaskPage",
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF9C27B0),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9C27B0),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF9C27B0),
          secondary: const Color(0xFFE1BEE7),
        ),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("Task Tabs")),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.checklist),
                  text: "Today's Task",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.pending_actions),
                  text: "Pending Task",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.event_available),
                  text: "Calendar Task",
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Icon(Icons.task, size: 100),
              Icon(Icons.task, size: 100),
              Icon(Icons.task, size: 100),
            ],
          ),
        ),
      ),
    );
  }
}
