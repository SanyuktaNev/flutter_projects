import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9C27B0), 
          title: const Center(
            child: Text(
              "Task Tabs",
              style: TextStyle(
                color: Colors.white,               
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,

            tabs: [
              Tab(
                iconMargin: EdgeInsets.only(bottom: 2),
                icon: Icon(Icons.call_made, color: Colors.white),
                text: "Today's Task",
              ),
              Tab(
                iconMargin: EdgeInsets.only(bottom: 2),
                icon: Icon(Icons.pending_actions, color: Colors.white),
                text: "Pending Task",
              ),
              Tab(
                iconMargin: EdgeInsets.only(bottom: 2),
                icon: Icon(Icons.calendar_month, color: Colors.white),
                text: "Calendar Task",
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            Center(
              child: Icon(Icons.task, size: 100, color: Color(0xFF9C27B0)),
            ),
            Center(
              child: Icon(Icons.task, size: 100, color: Color(0xFF9C27B0)),
            ),
            Center(
              child: Icon(Icons.task, size: 100, color: Color(0xFF9C27B0)),
            ),
          ],
        ),
      ),
    );
  }
}
