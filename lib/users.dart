import 'dart:ui'; // For ImageFilter
import 'package:aapkaparking/Fix.dart';
import 'package:aapkaparking/dueIn.dart';
import 'package:aapkaparking/paas.dart';
import 'package:aapkaparking/qrScanner.dart';
import 'package:aapkaparking/setting.dart';
import 'package:aapkaparking/verify.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Update this import with the correct path

class UserDash extends StatefulWidget {
  const UserDash({super.key});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  String _keyboardType = 'numeric'; // Default value

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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 15) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (userPhone != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('LoginUsers')
          .doc(userPhone)
          .get();

      return docSnapshot.data();
    }
    return null;
  }

  void _logout() {
    _showLogoutDialog();
  }

  Widget dueBottomSheet(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            child: Container(
              height: 100,
              color: const Color.fromARGB(0, 255, 193, 7),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.black),
                      const SizedBox(width: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Due In',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.yellow,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Qrscanner(),
                ),
              );
            },
            child: Container(
              height: 100,
              color: const Color.fromARGB(0, 255, 193, 7),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.black),
                      const SizedBox(width: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Due Out',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildUserCard(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        maxWidth: 450, // Adjust width to your needs
        maxHeight: 170, // Adjust height to your needs
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Slightly opaque background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Slight shadow
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_getGreeting()}, ${userData['userName'] ?? 'User'}',
                    style: GoogleFonts.nunito(
                      color: Color.fromARGB(255, 221, 200, 4),
                      fontSize: 25, // Base font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, color: const Color.fromARGB(255, 19, 19, 19)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phone no.: ${userData['uid'] ?? ''}',
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                    fontSize: 14, // Adjusted font size
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: const Color.fromARGB(255, 10, 10, 10)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Joined: ${DateFormat('dd MMM yyyy').format((userData['CreatedAt'] as Timestamp).toDate())}',
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                    fontSize: 14, // Adjusted font size
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridContainer(
      BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: const Color.fromARGB(255, 6, 6, 6),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        children: [
          _buildGridContainer(
              context, 'Due', const Color.fromARGB(255, 249, 105, 94), () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return dueBottomSheet(context);
              },
            );
          }),
          _buildGridContainer(context, 'Fix', Color.fromARGB(255, 98, 180, 247),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Fix(keyboardtype: _keyboardType)),
            );
          }),
          _buildGridContainer(
              context, 'Pass', const Color.fromARGB(255, 120, 238, 124), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Pass(keyboardtype: _keyboardType)),
            );
          }),
          _buildGridContainer(
              context, 'Settings', const Color.fromARGB(255, 245, 233, 120),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Setting()),
            );
          }),
        ],
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
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
            child: Text(
              'User Dashboard',
              style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 50,
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 82, 82),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Color.fromARGB(255, 5, 0, 0),
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
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return _buildUserCard(snapshot.data!);
              } else {
                return const Text('Error loading user data');
              }
            },
          ),
          const SizedBox(height: 0),
          Expanded(
            child: _buildGrid(),
          ),
        ],
      ),
    );
  }
}
