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
                  Lottie.asset(
                      'assets/animations/complete.json'),
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
      backgroundColor: const Color.fromARGB(255, 253, 253, 252),
      appBar: AppBar(
        title: Text(
          'Add Pricing',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Lottie.asset('assets/animations/Addpricing.json'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(5, 5),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      offset: const Offset(-5, -5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildVehicleSelector(),
                    const SizedBox(height: 16),
                    _buildTextField('Pricing of 30 minutes', Icons.timer,
                        _pricing30MinController),
                    const SizedBox(height: 16),
                    _buildTextField('Pricing of 1 hour', Icons.access_time,
                        _pricing1HourController),
                    const SizedBox(height: 16),
                    _buildTextField('Pricing of 120 minutes', Icons.watch_later,
                        _pricing120MinController),
                    const SizedBox(height: 16),
                    _buildTextField('Pass Price', Icons.monetization_on,
                        _passPriceController),
                    const SizedBox(height: 32),
                    _build3DButton(context, 'Submit', _savePricingData),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return GestureDetector(
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
          color: Colors.yellow.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedVehicleName ?? 'Choose Vehicle',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
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
                colors: [Color(0xFFFFF9C4), Color(0xFFFFF176)],
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
                                color: Colors.yellow.shade100,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.black),
                              ),
                              child: CheckboxListTile(
                                title: Text(vehicle,
                                    style:
                                        const TextStyle(color: Colors.black)),
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
      String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.yellow.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _build3DButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.yellow, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
