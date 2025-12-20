import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Signup',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF9C27B0),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF9C27B0),
          secondary: const Color(0xFFE1BEE7),
        ),
      ),
      home: const Splash2(),

    
      routes: {
        '/login': (context) =>  LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

class Splash2 extends StatelessWidget {
  const Splash2({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/my_assets.png',   
            height: 130,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 25),

          Text(
            "Welcome to MyApp",
            style: GoogleFonts.poppins(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          
          Text(
            "Registration Screen",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),

      nextScreen:  LoginScreen(),
      backgroundColor: const Color(0xFF9C27B0),
      splashTransition: SplashTransition.fadeTransition,
      duration: 2500,
      centered: true,
      splashIconSize: 250,
    );
  }
}
