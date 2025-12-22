import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'profile_page.dart';
import 'login_screen.dart';
import 'call_page.dart';
import 'visit_page.dart';
import 'task_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dashboard();
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF9C27B0)),
            child: Text(
              'Drawer',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
              );
            },
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 243, 239, 239),
        appBar: AppBar(
  title: const Center(
    child: Text(
      "Dashboard",
      style: TextStyle(color: Colors.white), // ✅ Title text white
    ),
  ),
  backgroundColor: const Color(0xFF9C27B0),
  iconTheme: const IconThemeData(
    color: Colors.white, // ✅ Drawer icon (hamburger) color white
  ),
),

        drawer: const MyDrawer(),

        body: SingleChildScrollView(
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 400,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  'assets/images/image1.jpg',
                  'assets/images/image2.jpg',
                  'assets/images/image3.jpg',
                  'assets/images/image4.jpg',
                  'assets/images/image5.jpg',
                ].map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 50),

              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = constraints.maxWidth / 3 - 40;
                  double cardHeight = cardWidth;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard("Call", Icons.call, cardWidth, cardHeight, context),
                      _buildCard("Visit", Icons.place, cardWidth, cardHeight, context),
                      _buildCard("Task", Icons.checklist, cardWidth, cardHeight, context),
                    ],
                  );
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    String title,
    IconData icon,
    double width,
    double height,
    BuildContext context,
  ) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          if (title == "Call") {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallPage())
            );
          } else if (title == "Visit") {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisitPage())
            );
          } else if (title == "Task") {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskPage())
            );
          }
        },
        splashColor: const Color.fromARGB(255, 184, 33, 243).withAlpha(30),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
