import 'dart:ui';

import 'package:aapkaparking/Admin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AddPrice extends StatefulWidget {
  const AddPrice({super.key});

  @override
  State<AddPrice> createState() => _AddPriceState();
}

class _AddPriceState extends State<AddPrice> {
  final TextEditingController _pricing30MinController = TextEditingController();
  final TextEditingController _pricing1HourController = TextEditingController();
  final TextEditingController _pricing120MinController =
      TextEditingController();
  final TextEditingController _passPriceController = TextEditingController();
  String? _selectedVehicleName; // Variable to store the selected vehicle name
  List<String> _vehicleNames = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicleNames();
  }

  Future<void> _fetchVehicleNames() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userPhone = user.phoneNumber;

      // Get reference to the "Vehicle" collection within the user's document in "AllUsers"
      final vehicleCollectionRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(userPhone)
          .collection('Vehicles');

      final querySnapshot = await vehicleCollectionRef.get();
      setState(() {
        _vehicleNames = querySnapshot.docs
            .map((doc) => doc['vehicleName'] as String)
            .toList();
      });
    }
  }

  Future<void> _savePricingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedVehicleName != null) {
      final userPhone = user.phoneNumber;

      // Get reference to the "Vehicle" collection within the user's document in "AllUsers"
      final vehicleCollectionRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(userPhone)
          .collection('Vehicles');

      // Query for the document where the "VehicleName" matches the selected vehicle name
      final querySnapshot = await vehicleCollectionRef
          .where('vehicleName', isEqualTo: _selectedVehicleName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the pricing fields in the matched document
        final docId = querySnapshot.docs.first.id;
        await vehicleCollectionRef.doc(docId).update({
          'Pricing30Minutes': _pricing30MinController.text,
          'Pricing1Hour': _pricing1HourController.text,
          'Pricing120Minutes': _pricing120MinController.text,
          'PassPrice': _passPriceController.text,
        });

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
                  Lottie.asset('assets/animations/complete.json'),
                  const SizedBox(height: 20),
                  const Text(
                    'Pricing added successfully!',
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
      } else {
        // If no matching document is found, show custom SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid vehicle.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pricing30MinController.dispose();
    _pricing1HourController.dispose();
    _pricing120MinController.dispose();
    _passPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      body: Padding(
          padding: const EdgeInsets.all(0.0),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 180,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Add vehicle',
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
                                  'Pricing',
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
                          height: 20,
                        ),
                        Column(
                          children: [
                            _buildVehicleSelector(),
                            const SizedBox(height: 10),
                            _buildTextField(
                                'Pricing of 30 minutes',
                                'Add price for 30 min',
                                _pricing30MinController),
                            const SizedBox(height: 10),
                            _buildTextField(
                                'Pricing of 60 minutes',
                                'Add price for 60 min',
                                _pricing1HourController),
                            const SizedBox(height: 10),
                            _buildTextField(
                                'Pricing of 120 minutes',
                                'Add price for 120 min',
                                _pricing120MinController),
                            const SizedBox(height: 10),
                            _buildTextField('Pass Price', 'Add price for pass',
                                _passPriceController),
                            const SizedBox(height: 32),
                            _build3DButton(context, 'Submit', _savePricingData),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 40,
                    left: -0,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminPage(), // Replace with your UserScreen widget
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.black,
                        ))),
              ],
            );
          })),
    );
  }

  Widget _buildVehicleSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Vehicle name',
        style: GoogleFonts.notoSansHanunoo(
          color: const Color.fromARGB(255, 29, 29, 29),
        ),
      ),
      GestureDetector(
        onTap: () async {
          final selectedVehicle = await _showVehicleDialog();
          if (selectedVehicle != null) {
            setState(() {
              _selectedVehicleName = selectedVehicle;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(0), // Sharp rectangle
            border: Border.all(
              color: Colors.black,
              width: 2.0, // 2 px black border
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedVehicleName ?? 'Choose an option',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Future<String?> _showVehicleDialog() async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String? selectedVehicle = _selectedVehicleName;

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [const Color.fromARGB(255, 225, 215, 206),const Color.fromARGB(255, 225, 215, 206)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20), // Space below close button
                  const Text(
                    'Select Vehicle',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _vehicleNames.map((String vehicle) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 255, 255, 255), // White background
                              borderRadius: BorderRadius.circular(0), // Sharp rectangle
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0, // 2 px black border
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                vehicle,
                                style: const TextStyle(color: Colors.black),
                              ),
                              value: selectedVehicle == vehicle,
                              activeColor: Colors.black,
                              checkColor: Colors.black,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  selectedVehicle = vehicle;
                                  Navigator.pop(context, selectedVehicle);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
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
  Widget _buildTextField(
      String hint, String hinttext, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Text(
          hinttext,
          style: GoogleFonts.notoSansHanunoo(
              color: Color.fromARGB(255, 29, 29, 29)),
        )),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansHanunoo(
              // Applying Google Font
              textStyle: const TextStyle(
                color: Colors.grey, // Hint text color
              ),
            ),

            // Background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0), // Sharp edges
              borderSide: const BorderSide(
                color: Colors.black, // Border color
                width: 2.0, // Border width
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0), // Sharp edges
              borderSide: const BorderSide(
                color: Colors.black, // Border color
                width: 2.0, // Border width
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0), // Sharp edges
              borderSide: const BorderSide(
                color: Colors.black, // Border color
                width: 2.0, // Border width
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity, // Full width
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0), // Sharp corners
        color: Colors.black, // Full black button
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7), // Darker shadow for 3D effect
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2), // Light shadow for 3D effect
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          "ADD PRICING", // Text updated to "ADD PRICING"
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color in white
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
