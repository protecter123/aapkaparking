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
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Update this import with the correct path

class UserDash2 extends StatefulWidget {
  const UserDash2({super.key});

  @override
  State<UserDash2> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash2> {
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
              color: Color.fromARGB(
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
                  builder: (_) => Qrscanner(),
                ),
              );
            },
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width *
                  0.49, // Adjust width as needed
              color: Color.fromARGB(
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
            borderRadius: BorderRadius.circular(20),
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
                          borderRadius: BorderRadius.circular(10),
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
                        backgroundColor: const Color.fromARGB(
                            255, 31, 249, 2), // Green background for "No"
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Greeting Row
          Row(children: [
            Expanded(
              child: Text(
                '${_getGreeting()}, ${userData['userName'] ?? 'User'}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Lottie.network(
                'https://lottie.host/f5b61010-8baf-4e9a-8fdf-2a6180a98fec/xsQlisfFJA.json', // Replace with your chosen Lottie animation URL
                fit: BoxFit.cover,
                height: 75,
                width: 75),
          ]),
          const SizedBox(height: 10),
          // Phone Number Row
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.phoneAlt, // Colorful phone icon
                color: Color.fromARGB(255, 19, 19, 19),
                size: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone no.: ${userData['uid'] ?? ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 17,
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
    IconData getIconForLabel(String label) {
      switch (label) {
        case "Due":
          return FontAwesomeIcons.clock;
        case "Fix":
          return FontAwesomeIcons.anchorLock;
        case "Pass":
          return FontAwesomeIcons.ticketAlt;
        case "Settings":
          return FontAwesomeIcons.cog;
        default:
          return FontAwesomeIcons.question;
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.grey.withOpacity(0.3)), // Subtle border
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
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image:const DecorationImage(
                    image: AssetImage(
                        'assets/animations/userbackimg2.jpg'), // Add your image path here
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      getIconForLabel(label),
                      color: const Color.fromARGB(
                          174, 0, 0, 0), // Softer color for the icon
                      size: 38,
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        builder: (context) => FpList(label: label),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
        image: const DecorationImage(
          image: AssetImage('assets/animations/userbackimg2.jpg'),
          fit: BoxFit.cover, // Ensures the image covers the entire area
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
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context); // Show exit dialog on back press
      },
      child: Scaffold(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                              backgroundColor: Colors.black,
                              color: Colors.white);
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
                      width:
                          10), // Add some space between the image and the text

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
      ),
    );
  }
}
