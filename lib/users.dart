import 'package:aapkaparking/Fix.dart';
import 'package:aapkaparking/dueIn.dart';
import 'package:aapkaparking/paas.dart';
import 'package:aapkaparking/qrScanner.dart';
import 'package:aapkaparking/setting.dart';
import 'package:aapkaparking/verify.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'bluetoothManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDash extends StatefulWidget {
  const UserDash({super.key});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  String _keyboardType = 'numeric'; // Default value
  final BluetoothManager bluetoothManager = BluetoothManager();

  @override
  void initState() {
    super.initState();
    _loadKeyboardType();
  }

  Future<void> _loadKeyboardType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _keyboardType = prefs.getString('keyboardType') ?? 'numeric';
    });
  }

  void _logout() {
    _showLogoutDialog();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Verify()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 250, 1, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 31, 249, 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dueBottomSheet(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Due(keyboardtype: _keyboardType),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        'Due In',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.yellow,
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Qrscanner(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        'Due Out',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      height: 150,
      width: 360,
      decoration: BoxDecoration(
        color: Colors.yellow[600],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'User Dashboard',
                  textStyle: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ),
          Positioned(
            right: 20,
            top: 60,
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          customAppBar(context),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  bottom: 220,
                  child: Container(
                    color: const Color.fromARGB(255, 251, 250, 250),
                    child: Center(
                      child: Container(
                        height: 350,
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(150),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.5),
                              offset: const Offset(0, 10),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildContainer(
                            context,
                            'Due',
                            Colors.red,
                            () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return dueBottomSheet(context);
                                },
                              );
                            },
                          ),
                          _buildContainer(
                            context,
                            'Fix',
                            Colors.blue,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Fix(keyboardtype: _keyboardType)),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildContainer(
                        context,
                        'Pass',
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Pass(keyboardtype: _keyboardType)),
                          );
                        },
                      ),
                      const Spacer(),
                      _buildSettingsButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(
      BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Settings()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
        child: Text(
          'Settings',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
