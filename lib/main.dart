import 'package:aapkaparking/Admin.dart';
import 'package:aapkaparking/sliding%20screen.dart';
import 'package:aapkaparking/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFFD700), // Gold (Yellow) color
      ),
      home: SplashVideoScreen(), // Initial route set to SplashVideoScreen
    );
  }
}

class SplashVideoScreen extends StatefulWidget {
  @override
  _SplashVideoScreenState createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _textAnimationController;

  @override
  void initState() {
    super.initState();

    _textAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _textAnimationController.forward().then((_) {
      Future.delayed(Duration(milliseconds: 2150), () async {
        await _navigateToNextScreen(); // Navigate based on authentication state
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get the user's phone number
    String? phoneNumber = user.phoneNumber;

    if (phoneNumber != null) {
      // User is logged in, check if they are an admin or regular user
      final userType = await _getUserType(phoneNumber);
      if (userType == 'user') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UserDash()),
        );
      } else if (userType == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      }
    } else {
      // Handle case where phone number is null, though it shouldn't be in your use case
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  } else {
    // No user is logged in, navigate to the sliding screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }
}


  

Future<String> _getUserType(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('AllUsers').doc(uid);

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    return 'admin'; // UID found in 'AllUsers' collection, user is an admin
  } else {
    return 'user'; // UID not found, user is a regular user
  }
}

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset('assets/animations/splash.json'),
          ),
        ],
      ),
    );
  }
}
