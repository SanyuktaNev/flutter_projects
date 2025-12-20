import 'package:flutter/material.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9C27B0), 
          title: const Center(
            child: Text(
              "Call Tabs",
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
                text: "Today's Call",
              ),
              Tab(
                iconMargin: EdgeInsets.only(bottom: 2),
                icon: Icon(Icons.pending_actions, color: Colors.white),
                text: "Pending Call",
              ),
              Tab(
                iconMargin: EdgeInsets.only(bottom: 2),
                icon: Icon(Icons.calendar_month, color: Colors.white),
                text: "Calendar Call",
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            Center(
              child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0)),
            ),
            Center(
              child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0)),
            ),
            Center(
              child: Icon(Icons.call, size: 100, color: Color(0xFF9C27B0)),
            ),
          ],
        ),
      ),
    );
  }
}
