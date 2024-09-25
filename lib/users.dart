import 'dart:ui'; // For ImageFilter
import 'package:aapkaparking/Fix.dart';
import 'package:aapkaparking/bluetoothShowScreen.dart';
import 'package:aapkaparking/dueIn.dart';
import 'package:aapkaparking/fpList.dart';
import 'package:aapkaparking/paas.dart';
import 'package:aapkaparking/qrScanner.dart';
import 'package:aapkaparking/verify.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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

  Future<void> _saveKeyboardType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('keyboardType', type);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedKeyboardType = _keyboardType;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    24.0), // Increased padding for more space
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Stretch items horizontally
                  children: [
                    // Title of the dialog
                    Text(
                      'Select Keyboard Type',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center, // Center title
                    ),
                    const SizedBox(height: 20),

                    // Numeric checkbox
                    CheckboxListTile(
                      title: Text(
                        'Numeric',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      value: selectedKeyboardType == 'numeric',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            selectedKeyboardType = 'numeric';
                          });
                        }
                      },
                      activeColor: const Color.fromARGB(255, 235, 197, 103),
                      checkColor: Colors.black,
                    ),
                    const SizedBox(height: 8),

                    // Alphanumeric checkbox
                    CheckboxListTile(
                      title: Text(
                        'Alphanumeric',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      value: selectedKeyboardType == 'alphanumeric',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            selectedKeyboardType = 'alphanumeric';
                          });
                        }
                      },
                      activeColor: Colors.yellow.shade700,
                      checkColor: Colors.black,
                    ),
                    const SizedBox(height: 24),

                    // Set button
                    ElevatedButton(
                      onPressed: () {
                        _saveKeyboardType(selectedKeyboardType);
                        setState(() {
                          _keyboardType = selectedKeyboardType;
                        });
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Set',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    _showLogoutDialog(context);
  }

  Widget dueBottomSheet(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 254, 254),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              width: MediaQuery.of(context).size.width *
                  0.5, // Adjust width as needed
              color: const Color.fromARGB(
                  0, 0, 0, 0), // Changed to transparent to detect taps
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 60.0),
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
                  builder: (_) => const Qrscanner(),
                ),
              );
            },
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width *
                  0.49, // Adjust width as needed
              color: const Color.fromARGB(
                  0, 0, 0, 0), // Changed to transparent to detect taps
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the left
              children: [
                const Row(
                  children: [
                    Text(
                      'Log out',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align buttons to the right
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Verify(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // White background for "Yes"
                        side: const BorderSide(
                            color: Colors.black), // Black border for "Yes"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:const Color.fromARGB(255, 7, 7, 7), // Green background for "No"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Color.fromARGB(255, 254, 254, 254), fontSize: 18),
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
      margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0),
      padding: const EdgeInsets.only(left: 30.0, right: 30, top: 0, bottom: 0),
      constraints: const BoxConstraints(
        maxWidth: 450, // Keep original width
        maxHeight: 160, // Keep original height
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Greeting Row
          Row(children: [
            Expanded(
              child: Text(
                '${_getGreeting()}, ${userData['userName'] ?? 'User'}',
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 1, 1, 1),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Lottie.network(
                'https://lottie.host/f5b61010-8baf-4e9a-8fdf-2a6180a98fec/xsQlisfFJA.json', // Replace with your chosen Lottie animation URL
                fit: BoxFit.cover,
                height: 78,
                width: 85),
          ]),
          const SizedBox(height: 10),
          // Phone Number Row
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.phoneAlt, // Colorful phone icon
                color: Color.fromARGB(255, 19, 19, 19),
                size: 15,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone no.: ${userData['uid'] ?? ''}',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(179, 37, 37, 37),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Join Date Row
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.calendarAlt, // Colorful calendar icon
                color: Color.fromARGB(255, 2, 2, 2),
                size: 15,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Joined: ${DateFormat('dd MMM yyyy').format((userData['CreatedAt'] as Timestamp).toDate())}',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(179, 37, 37, 37),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridContainer(BuildContext context, String label, Color color,
      VoidCallback onTap, String Blocknum) {
    // Determine border radius based on Blocknum
    BorderRadius borderRadius;
    switch (Blocknum) {
      case '1': // Top-left rounded
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.zero,
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        );
        break;
      case '2': // Top-right rounded
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.zero,
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        );
        break;
      case '3': // Bottom-right rounded
        borderRadius = const BorderRadius.only(
          bottomRight: Radius.zero,
          topLeft: Radius.zero,
          topRight: Radius.zero,
          bottomLeft: Radius.circular(12),
        );
        break;
      case '4': // Bottom-left rounded
        borderRadius = const BorderRadius.only(
          bottomRight: Radius.circular(12),
          topLeft: Radius.zero,
          topRight: Radius.zero,
          bottomLeft: Radius.zero,
        );
        break;
      default:
        borderRadius =
            BorderRadius.circular(12); // Default to all corners rounded
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main container
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius, // Apply conditional border radius
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ), // Subtle border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      borderRadius, // Ensure the inner container matches
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: GoogleFonts.inconsolata(
                          color: Colors.black87,
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Icon in top-right corner (if not Settings or Due)
          if (label != "Settings" && label != 'Due' && label != 'Pass')
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (label == "Fix") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FpList(label: label),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.list,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          if (label != "Settings" && label != 'Due' && label != 'Fix')
            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  if (label == "Pass") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FpList(label: label),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.list,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 17,
        mainAxisSpacing: 17,
        shrinkWrap: true,
        children: [
          _buildGridContainer(
              context, 'Due', const Color.fromARGB(255, 225, 215, 206), () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return dueBottomSheet(context);
              },
            );
          }, '1'),
          _buildGridContainer(
              context, 'Fix', const Color.fromARGB(255, 225, 215, 206), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Fix(keyboardtype: _keyboardType)),
            );
          }, '2'),
          _buildGridContainer(
              context, 'Pass', const Color.fromARGB(255, 225, 215, 206), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Pass(keyboardtype: _keyboardType)),
            );
          }, '3'),
          _buildGridContainer(
              context, 'Settings', const Color.fromARGB(255, 225, 215, 206),
              () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Setting()),
            // );
            _getSettings();
          }, '4'),
        ],
      ),
    );
  }

  void _getSettings() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: const Color.fromARGB(255, 244, 244, 158),
          height: 150, // Adjust height as needed
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    _showSettingsDialog();
                  },
                  child: Container(
                    height: 150,
                    width: 160,
                    color: const Color.fromARGB(255, 244, 244, 158),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.keyboard,
                          color: Colors.black,
                          size: 50, // Increase icon size
                        ), // Colorful icon
                        SizedBox(height: 10),
                        Text('Keyboard Setting',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 5, 5, 5))), // Label
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1, // Separator line width
                color:
                    const Color.fromARGB(255, 9, 9, 9), // Separator line color
                height: 80, // Separator line height
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrintOptionsScreen()),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: 160,
                    color: const Color.fromARGB(255, 244, 244, 158),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.print,
                          color: Colors.black,
                          size: 50, // Increase icon size
                        ), // Colorful icon
                        SizedBox(height: 10),
                        Text('printer Setting',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 2, 2, 2))), // Label
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(0, 225, 215, 206),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 110,
            top: 55,
            child: Text(
              'User Dashboard',
              style: GoogleFonts.lora(
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
                  color: const Color.fromARGB(
                      0, 255, 82, 82), // Transparent background
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

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(5), // Rounded corners for the dialog
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content to the left
                  children: [
                    // "Exit app" heading
                    const Text(
                      'Exit app',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Confirmation message
                    const Text(
                      'Do you want to exit the app?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    // Row with "Yes" and "No" buttons
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align buttons to the right
                      children: [
                        // "Yes" button with transparent background (only text)
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Close dialog and exit app
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // "No" button with green background
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Close dialog, stay in app
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 124, 244,
                                109), // Green background for "No"
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context); // Show exit dialog on back press
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 225, 215, 206),
        body: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 234, 77, 255),
                          Color.fromARGB(255, 238, 133, 252),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 40.0,
                        sigmaY: 40.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.yellow.shade200
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 30.0,
                        sigmaY: 30.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 70,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 243, 255, 77),
                          Color.fromARGB(255, 251, 230, 190)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 30.0,
                        sigmaY: 30.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                customAppBar(context),
                const SizedBox(height: 0),
                Padding(
                  padding: const EdgeInsets.only(top: 115.0),
                  child: Center(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUserData(),
                      builder: (context, snapshot) {
                        return _buildUserCard(snapshot.data!);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/animations/tesla_car_PNG30.png', // Replace with your actual image asset path
              width: 400,
              height: 160,
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/animations/OIP (4)4.jpeg'), // Background image path
                  fit:
                      BoxFit.cover, // Cover the entire container with the image
                ),
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width (1px)
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50), // Rounded top-left corner
                  topRight: Radius.circular(50), // Rounded top-right corner
                ),
              ),
              height: 420, // Example height, can be adjusted
              width:
                  MediaQuery.of(context).size.width - 30, // Full screen width
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Stick content to bottom
                children: [
                  _buildGrid(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container for the image
                        ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.grey, // Grey filter for the logo
                            BlendMode.srcATop, // Blend mode
                          ),
                          child: Image.asset(
                            'assets/aapka logo.webp', // Image asset path
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const SizedBox(
                            width: 10), // Space between the logo and text
                        const Text(
                          'Aapka Parking \u00A9',
                          style: TextStyle(
                            color: Colors.grey, // Text color
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
