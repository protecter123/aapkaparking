import 'dart:io';
import 'dart:ui';
import 'package:aapkaparking/Admin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final TextEditingController vehicleNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  void _getImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150, // Adjust height as needed
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    setState(() {
                      if (pickedFile != null) {
                        _image = File(pickedFile.path);
                      }
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 160,
                    color: const Color.fromARGB(0, 0, 0, 0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            size: 50,
                            color: Colors.blueAccent), // Colorful icon
                        SizedBox(height: 10),
                        Text('Camera',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent)), // Label
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1, // Separator line width
                color: Colors.grey, // Separator line color
                height: 80, // Separator line height
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      if (pickedFile != null) {
                        _image = File(pickedFile.path);
                      }
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 160,
                    color: const Color.fromARGB(0, 0, 0, 0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library,
                            size: 50,
                            color: Colors.greenAccent), // Colorful icon
                        SizedBox(height: 10),
                        Text('Gallery',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.greenAccent)), // Label
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

  Future<void> _saveVehicleDetails() async {
    if (_image == null && vehicleNameController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide Vehicle name and Image.')),
      );
      return;
    }
    if (_image == null) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide Vehicle Image.')),
      );
      return;
    }
    if (vehicleNameController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide Vehicle name.')),
      );
      return;
    }

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(backgroundColor:Color.fromARGB(255, 206, 200, 200),color: Colors.black,), // Show loader
        );
      },
    );

    try {
      // Get the current user's phone number or unique ID
      final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

      if (phoneNumber.isEmpty) {
        // Handle case where phoneNumber is null
        Navigator.of(context).pop(); // Close loader dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Check if the vehicle name already exists
      final firestoreRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(phoneNumber)
          .collection('Vehicles');

      final querySnapshot = await firestoreRef
          .where('vehicleName', isEqualTo: vehicleNameController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Close loader
        Navigator.of(context).pop(); // Close loader dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle already added')),
        );
        return;
      }

      // Upload the image to Firebase Storage
      final fileName = path.basename(_image!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicles/$phoneNumber/$fileName');
      final uploadTask = await storageRef.putFile(File(_image!.path));

      // Get the download URL of the uploaded image
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save the vehicle details in Firestore
      await firestoreRef.doc().set({
        'vehicleName': vehicleNameController.text.trim(),
        'vehicleImage': downloadUrl,
        'pricingdone': false
      });

      // Close the loader
      Navigator.of(context).pop(); // Close loader dialog

      // Show success dialog with Lottie animation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                    'assets/animations/complete.json'), // Replace with your Lottie file URL
                const SizedBox(height: 20),
                const Text(
                  'Vehicle added successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Close the loader if there's an error
      Navigator.of(context).pop(); // Close loader dialog
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicle details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
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
                  left: 80,
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
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 250,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                'Add Vehicle',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 50 : 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                'Name',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 50 : 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  const Color.fromARGB(255, 13, 13, 13),
                              child: GestureDetector(
                                onTap: () {
                                  _getImage(); // Add parentheses to call the function
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 225, 215, 206),
                                  radius: 55,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : null,
                                  child: _image == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Color.fromARGB(255, 5, 5, 5),
                                          size: 60,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: ElevatedButton(
                                onPressed: () {
                                  _getImage(); // Add parentheses to call the function
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor:
                                      const Color.fromARGB(255, 8, 8, 8),
                                  padding: EdgeInsets.all(8), // Button color
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: Text(
                            'Add vehicle name',
                            style: GoogleFonts.notoSansHanunoo(
                                color: Color.fromARGB(255, 29, 29, 29)),
                          )),
                          const SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            height: 52,
                            child: TextField(
                              controller: vehicleNameController,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(0), // Sharp edges
                                  borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2), // 2 px black border
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(0), // Sharp edges
                                  borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2), // 2 px black border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(0), // Sharp edges
                                  borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2), // 2 px black border
                                ),
                                hintText: 'Vehicle name',
                                hintStyle: GoogleFonts.notoSansHanunoo(
                                  color: Colors.grey,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveVehicleDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Full black color
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(0), // Sharp corners
                            ),
                            elevation: 10, // Elevation for the 3D effect
                            shadowColor: Colors.black
                                .withOpacity(0.5), // Shadow for 3D effect
                          ),
                          child: const Text(
                            'SAVE VEHICLE DETAILS', // Updated button text
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18), // White text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: 40,
                    left: -10,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 37,
                          color: Colors.black,
                        ))),
              ],
            );
          })),
    );
  }
}
