import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool _buttonEnabled = false;

  // Function to save user data
  void saveUser() async {
    final String phoneNumber = '+91' + phoneController.text.trim();
    final String currentAdminId =
        FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    final String userName = nameController.text.trim();
    final Map<String, dynamic> userData = {
      'uid': phoneNumber,
      'userName': userName,
      'CreatedAt': DateTime.now(),
      'isdeleted': false
    };
    final Map<String, dynamic> AdminData = {
      'uid': currentAdminId,
      'ParkingSubscribePackage': 0,
      'CreatedAt': DateTime.now(),
      'Usertype': 'Admin',
      'isdeleted': false
    };
    // Get the current admin's phone number

    if (currentAdminId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No admin logged in')),
      );
      return;
    }

    try {
      // Save user data in "All Users" collection
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentAdminId)
          .set(AdminData);
      await FirebaseFirestore.instance
          .collection('loginUsers')
          .doc(phoneNumber)
          .set(userData);

      // Save user data in current admin's "Users" collection
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentAdminId)
          .collection('Users')
          .doc(phoneNumber)
          .set(userData);

      // Show success dialog
      _showSuccessDialog();

      phoneController.clear();
      nameController.clear();
      setState(() {
        _buttonEnabled = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $error')),
      );
    }
  }

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/complete.json',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'New User Added Successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add User',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/User.json',
                height: 450,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    hintText: 'Enter user name',
                    hintStyle:
                        const TextStyle(color: Colors.brown, fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.person, // User icon
                      color: Colors.black, // Icon color
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48, // Set appropriate width for the icon box
                      minHeight: 48, // Set appropriate height for the icon box
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _buttonEnabled =
                          value.isNotEmpty && phoneController.text.length == 10;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    hintText: 'Enter user number',
                    hintStyle:
                        const TextStyle(color: Colors.brown, fontSize: 14),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(right: 5.0, left: 10),
                      child: Text(
                        '+91 |',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 11, 11, 11),
                        ),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _buttonEnabled =
                          value.length == 10 && nameController.text.isNotEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _buttonEnabled ? saveUser : null,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow.shade600,
                        Colors.yellow.shade700,
                        Colors.yellow.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade900.withOpacity(0.4),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
