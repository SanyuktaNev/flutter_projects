import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'services/auth_service.dart';
import 'fcm_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM silently
  await FcmService.instance.initialize();

  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
      home: Splash2(isLoggedIn: isLoggedIn),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/welcome': (context) => WelcomeScreen(),
      },
    );
  }
}

class Splash2 extends StatelessWidget {
  final bool isLoggedIn;

  const Splash2({super.key, required this.isLoggedIn});

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
      nextScreen: isLoggedIn ? const WelcomeScreen() : LoginScreen(),
      backgroundColor: const Color(0xFF9C27B0),
      splashTransition: SplashTransition.fadeTransition,
      duration: 2500,
      centered: true,
      splashIconSize: 250,
    );
  }
}
