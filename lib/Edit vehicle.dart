import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class EditVehicle extends StatefulWidget {
  const EditVehicle({super.key});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Vehicle List',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
            .collection('Vehicles')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow,));
          }

          final vehicles = snapshot.data!.docs;

          if (vehicles.isEmpty) {
            return const Center(
              child: Text(
                'No vehicles found.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final vehicleName =
                  _capitalizeFirstLetter(vehicle['vehicleName'] ?? '');
              final vehicleImage = vehicle['vehicleImage'] ?? '';
              final pricing30Minutes = vehicle['Pricing30Minutes'] ?? 'N/A';
              final pricing1Hour = vehicle['Pricing1Hour'] ?? 'N/A';
              final pricing120Minutes = vehicle['Pricing120Minutes'] ?? 'N/A';
              final passPrice = vehicle['PassPrice'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 251, 250, 246),
                        Color.fromARGB(255, 247, 244, 223),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1),
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
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: vehicleImage.isNotEmpty
                            ? Image.network(
                                vehicleImage,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(color: Colors.yellow,));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              )
                            : const Icon(Icons.directions_car, size: 80),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      vehicleName,
                                      style: GoogleFonts.nunito(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildPassPriceRow('Pass', passPrice),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10.0,
                              runSpacing: 8.0,
                              children: [
                                _buildPriceRow('30 min', pricing30Minutes,
                                    Icons.timer, Colors.red),
                                _buildPriceRow('1 hour', pricing1Hour,
                                    Icons.access_time, Colors.blue),
                                _buildPriceRow('120 min', pricing120Minutes,
                                    Icons.watch_later, Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            _deleteVehicle(vehicle.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Widget _buildPriceRow(String label, String price, IconData icon, Color iconColor) {
  return Row(
    children: [
      Icon(icon, color: iconColor),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          '$label: ₹$price',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}


  Widget _buildPassPriceRow(String label, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.black),
          const SizedBox(width: 5),
          Text(
            '$label: ₹$price',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(String docId) async {
    final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    await FirebaseFirestore.instance
        .collection('AllUsers')
        .doc(phoneNumber)
        .collection('Vehicles')
        .doc(docId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
    }
  }
}
