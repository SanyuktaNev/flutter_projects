import 'package:flutter/material.dart';
import 'package:social_media_app/components/text_field.dart';
import 'package:social_media_app/components/button.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

final emailTextController = TextEditingController();
final passwordTextController = TextEditingController();


void signIn() async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailTextController.text,
    password: passwordTextController.text,
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 121, 166, 244),
      body: SafeArea(  
       child: Center(  
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            const Icon( 
              Icons.favorite,
              size: 100,
            ),
            const SizedBox(height: 50),

           Text(
              'Welcome back!',
              style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              ),
            ),

            const SizedBox(height: 25),
            MyTextField(
              controller: emailTextController, 
              hintText: "Email Id", 
              obscureText: false,
              ),

            const SizedBox(height: 25),
            MyTextField(
              controller: passwordTextController, 
              hintText: "Password", 
              obscureText: true,
              ), 


            const SizedBox(height: 20),
            MyButton(
              onTap: signIn,
              text: 'Sign In',
              ),

          const SizedBox(height: 10),

          Row(   
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(   
                "Not a member?",
                style: TextStyle(   
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onTap,
              child: const Text(  
                "Register Now",
                style: TextStyle(   
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ) ,
              ),
              ),
            ],
          ),

          ],
        ),
        ),
       ),
      ),
    );
  }
}