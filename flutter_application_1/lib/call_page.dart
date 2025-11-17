import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dashboard",
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
            title: const Center(child: Text("Call Tabs")),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.call_made),
                  text: "Today's Call",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.pending_actions),
                  text: "Pending Call",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.calendar_month),
                  text: "Calendar Call",
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Icon(Icons.call, size: 100),
              Icon(Icons.call, size: 100),
              Icon(Icons.call, size: 100),
            ],
          ),
        ),
      ),
    );
  }
}
