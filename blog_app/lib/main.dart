import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Vedu Dumbass",
    theme: ThemeData( 
      primarySwatch: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  home: MyHomePage(),
  );
}
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "";

  void changeText(String text) {
    this.setState(() {
      this.text = text;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: Text(   
          'Hello World'
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(children: <Widget>[TextInputWidget(this.changeText), Text(this.text)])
    );
  }
}




class TextInputWidget extends StatefulWidget {

  final Function(String) callback;

  TextInputWidget(this.callback);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final controller = TextEditingController();
  

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void click() {
     widget.callback(controller.text);
    controller.clear();
  }

  
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: this.controller,
        decoration: InputDecoration(  
          prefixIcon: Icon(Icons.message), 
          labelText: "Type a message",
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            splashColor: const Color.fromARGB(255, 224, 21, 21),
            tooltip: "Post Message",
            onPressed: this.click,
           )),
      );
  }
}
