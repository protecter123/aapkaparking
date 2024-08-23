import 'package:aapkaparking/bluetoothShowScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add Google Fonts for Nunito

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _keyboardType = 'numeric';
  @override
  void initState() {
    super.initState();
    // Initialize animation controller and scale animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadKeyboardType();
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadKeyboardType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _keyboardType = prefs.getString('keyboardType') ?? 'numeric';
    });
  }

  Future<void> _saveKeyboardType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('keyboardType', type);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Local variable to track the current selection
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

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow, // Yellow AppBar background
        centerTitle: true, // Center the title
        title: Text(
          'Settings',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ), // Nunito font for title
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align buttons to the start
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) =>
                  _animationController.forward(), // Scale up on tap down
              onTapUp: (_) =>
                  _animationController.reverse(), // Scale down on tap up
              onTap: _showSettingsDialog,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Text(
                      'Keyboard Setting',
                      style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTapDown: (_) =>
                  _animationController.forward(), // Scale up on tap down
              onTapUp: (_) =>
                  _animationController.reverse(), // Scale down on tap up
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrintOptionsScreen()),
                );
              },
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Text(
                      'Connect Printer',
                      style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
