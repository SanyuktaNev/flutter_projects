import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VisitPage",
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
            title: const Center(child: Text("Visit Tabs")),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.location_on),
                  text: "Today's Visit",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.pending_actions),
                  text: "Pending Visit",
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.calendar_today),
                  text: "Calendar Visit",
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Icon(Icons.location_city, size: 100),
              Icon(Icons.location_city, size: 100),
              Icon(Icons.location_city, size: 100),
            ],
          ),
        ),
      ),
    );
  }
}
