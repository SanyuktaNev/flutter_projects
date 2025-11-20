import 'package:flutter/material.dart';
import 'package:social_media_app/components/button.dart';
import 'package:social_media_app/components/text_field.dart';

class RegisterPage extends StatefulWidget{

  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    final emailTextController = TextEditingController();
    final passwordTextController = TextEditingController();
    final confirmPasswordTextController = TextEditingController();

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
              "Let's create an account for you",
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
             

            const SizedBox(height: 25),
            MyTextField(
              controller: confirmPasswordTextController, 
              hintText: " Confirm Password", 
              obscureText: true,
              ), 

            const SizedBox(height: 20),
            MyButton(
              onTap: () {},
              text: 'Sign Up',
              ),

          const SizedBox(height: 10),

          Row(   
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(   
                "Already have an account?",
                style: TextStyle(   
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onTap,
              child: const Text(  
                "Login now",
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