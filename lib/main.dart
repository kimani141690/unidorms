import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unidorms/screens/booking_summary_screen.dart';
import 'package:unidorms/screens/dates_screen.dart';
import 'package:unidorms/screens/display_reviews.dart';
import 'package:unidorms/screens/guest.dart';
import 'package:unidorms/screens/maintenance.dart';
import 'package:unidorms/screens/reservation_screen.dart';
import 'package:unidorms/screens/write_reviews.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notice_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/catalogue_screen.dart';
import 'package:unidorms/models/roomlist.dart';

import 'screens/maintenance.dart';
import 'screens/guest.dart';
import 'screens/display_reviews.dart';
import 'screens/write_reviews.dart'; // Import WriteReviewScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await populateRooms();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniDorms',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/notice': (context) => NoticeScreen(),
        '/profile': (context) => ProfileScreen(
          userData: {},
          onProfileUpdated: (updatedData) {},
        ),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/catalogue': (context) => CatalogueScreen(),
        '/reservation': (context) => ReservationsScreen(),
        '/maintenance': (context) => MaintenanceScreen(),
        '/guest': (context) => GuestVisitRequestScreen(),
        '/reviews': (context) => ReviewScreen(),
        '/write-review': (context) => WriteReviewScreen(), // Add WriteReviewScreen route
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
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

