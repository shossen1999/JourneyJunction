import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journey/home.dart';
import 'package:journey/login_page.dart';
import 'package:journey/register_page.dart'; // Ensure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCapL74RdeC63za16_lrMcBKYDQe7CDSJ4",
      appId: '1:509855341431:android:7cf9e2f66d103f6ef9df72',
      messagingSenderId: '509855341431',
      projectId: 'journey-feda2',
      databaseURL: 'https://journey-feda2.firebaseio.com',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiteBooker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Set the initial route
      routes: {
        '/home': (context) => HomePage(),
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(), // Define the home route
      },
    );
  }
}
