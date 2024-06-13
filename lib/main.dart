import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unidorms/screens/catalogue_screen.dart';
import 'package:unidorms/screens/home_screen.dart';
import 'package:unidorms/screens/login_screen.dart';
import 'package:unidorms/screens/notice_screen.dart';
import 'package:unidorms/screens/profile_screen.dart';
import 'package:unidorms/screens/registration_screen.dart';
import 'package:unidorms/screens/splash_screen.dart';
import 'package:unidorms/screens/forgot_password_screen.dart';
import 'package:unidorms/models/roomlist.dart'; // Import the roomlist script

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  //calling the  adding rooms function to add room to db on initia;lization
  await populateRooms();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniDorms',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Use AuthWrapper to handle initial routing
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/notice': (context) => NoticeScreen(),
        '/profile': (context) => ProfileScreen(
              userData: {},
              onProfileUpdated: (updatedData) {}, // Placeholder
            ),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/catalogue': (context) =>
            CatalogueScreen(), // Add the CatalogueScreen route
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
