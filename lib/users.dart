import 'dart:ui'; // For ImageFilter
import 'package:aapkaparking/Fix.dart';
import 'package:aapkaparking/bluetoothShowScreen.dart';
import 'package:aapkaparking/dueIn.dart';
import 'package:aapkaparking/duelist.dart';
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Keyboard Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        'Numeric',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.black,
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
                      activeColor: selectedKeyboardType == 'numeric'
                          ? const Color.fromARGB(255, 235, 197, 103)
                          : Colors.white,
                      checkColor: Colors.black,
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Alphanumeric',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.black,
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
                      activeColor: selectedKeyboardType == 'alphanumeric'
                          ? Colors.yellow.shade700
                          : Colors.white,
                      checkColor: Colors.black,
                    ),
                    const SizedBox(height: 20),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Set',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Nunito',
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
      constraints: const BoxConstraints(
        maxWidth: 450, // Keep original width
        maxHeight: 170, // Keep original height
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6DC8F3), // Gradient start
            Color(0xFF73A1F9), // Gradient end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(12), // Rounded corners for modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Subtle shadow
            blurRadius: 10,
            offset: const Offset(0, 8), // Slightly deeper shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Row
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_getGreeting()}, ${userData['userName'] ?? 'User'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.handPeace, // A colorful hand icon
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Phone Number Row
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.phoneAlt, // Colorful phone icon
                color: const Color.fromARGB(255, 255, 0, 0),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone no.: ${userData['uid'] ?? ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
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
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Joined: ${DateFormat('dd MMM yyyy').format((userData['CreatedAt'] as Timestamp).toDate())}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
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
    // Define icons for each label
    IconData getIconForLabel(String label) {
      switch (label) {
        case "Due":
          return FontAwesomeIcons.clock; // Due: clock icon
        case "Fix":
          return FontAwesomeIcons.tools; // Fix: tools icon
        case "Pass":
          return FontAwesomeIcons.ticketAlt; // Pass: ticket icon
        case "Settings":
          return FontAwesomeIcons.cog; // Settings: settings icon
        default:
          return FontAwesomeIcons.question; // Default icon
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main container
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 150, // Set fixed width
                height: 150, // Adjust height to fit larger icon and label
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      129, 255, 255, 255), // Background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      getIconForLabel(label), // Fetch icon based on label
                      color: const Color.fromARGB(255, 9, 9, 9), // Icon color
                      size: 40, // Larger icon size
                    ),
                    const SizedBox(height: 10), // Space between icon and label
                    FittedBox(
                      fit: BoxFit
                          .scaleDown, // Ensures the text scales down to fit inside
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          color: const Color.fromARGB(255, 6, 6, 6),
                          fontSize: 23, // Adjust label font size
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Adds ellipsis if the text is too long
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Icon in top-right corner (if not Settings)
          if (label != "Settings" && label != 'Due')
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (label == "Fix" || label == "Pass") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FpList(label: label)), // Navigate to FpList
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(102, 255, 255, 255),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.list, // List icon from Font Awesome
                    color: Colors.black, // Icon color
                    size: 25, // Icon size
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
          _buildGridContainer(
              context, 'Fix', Color.fromARGB(255, 152, 123, 244), () {
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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Setting()),
            // );
            _getSettings();
          }),
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
                        const FaIcon(
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
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 252, 251, 251),
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
          Positioned(
            right: 110,
            top: 55,
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
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
      body: Column(
        children: [
          Stack(
            children: [
              customAppBar(context),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(top: 125.0),
                child: Center(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                            backgroundColor: Colors.black, color: Colors.white);
                      } else if (snapshot.hasData) {
                        return _buildUserCard(snapshot.data!);
                      } else {
                        return const Text('Error loading user data');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 0),
            ],
          ),
          Expanded(
            child: _buildGrid(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, left: 100),
            child: Row(
              children: [
                // Container for the image
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors
                        .grey, // The color you want to apply (in this case, grey)
                    BlendMode
                        .srcATop, // Blend mode to replace the original color
                  ),
                  child: Image.asset(
                    'assets/aapka logo.webp', // Replace with your actual image asset path
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(
                    width: 10), // Add some space between the image and the text

                // Container for the text
                Container(
                  child: const Text(
                    'Aapka Parking \u00A9',
                    style: TextStyle(
                      color: Colors.grey, // Dark yellow color (GoldenRod)
                      fontSize: 24, // Set the font size
                      fontWeight: FontWeight.bold, // Make the text bold
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
