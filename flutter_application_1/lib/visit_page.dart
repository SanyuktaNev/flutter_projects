import 'package:flutter/material.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visit Page"),
      ),
      body: const Center(
        child: Text(
          "This is the Visit Page",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
