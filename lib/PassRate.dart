import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reciept.dart';

class Passrate extends StatefulWidget {
  final String imgUrl;
  final String keyboardtype;

  const Passrate({super.key, required this.imgUrl, required this.keyboardtype});

  @override
  _PassrateState createState() => _PassrateState();
}

class _PassrateState extends State<Passrate> {
  int? _selectedContainerIndex;
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? pricingData;
  String? adminPhoneNumber = '';
  String currentUserPhoneNumber = '';
  Future<void> fetchPricingDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserPhoneNumber = currentUser?.phoneNumber ?? 'unknown';

    try {
      // Retrieve the admin phone number from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      adminPhoneNumber = prefs.getString('AdminNum');

      if (adminPhoneNumber != null) {
        // Reference to the admin's Vehicles collection
        CollectionReference vehiclesCollection = FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(adminPhoneNumber)
            .collection('Vehicles');

        // Fetch pricing details based on the vehicle image URL
        var snapshot = await vehiclesCollection
            .where('vehicleImage', isEqualTo: widget.imgUrl)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            pricingData = snapshot.docs.first.data() as Map<String, dynamic>;
          });
        } else {
          setState(() {
            pricingData = null; // Handle no matching vehicle
          });
        }
      } else {
        // Handle case where adminPhoneNumber is not in SharedPreferences
        setState(() {
          pricingData = null;
        });
      }
    } catch (e) {
      print('Error fetching pricing details: $e');
      setState(() {
        pricingData = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPricingDetails();
  }

  void _generateReceipt() async {
    if (_selectedContainerIndex != null &&
        _controller.text.isNotEmpty &&
        pricingData != null) {
      var selectedRate = _selectedContainerIndex == 0
          ? '1 Month Pass'
          : _selectedContainerIndex == 1
              ? '2 Month Pass'
              : '3 Month Pass';

      // Calculate the price based on the selected option
      var price = _selectedContainerIndex == 0
          ? pricingData!['PassPrice']
          : _selectedContainerIndex == 1
              ? (int.tryParse(pricingData!['PassPrice'])! * 2).toString()
              : (int.tryParse(pricingData!['PassPrice'])! * 3).toString();

      // Convert price to integer
      int priceAsInt = int.tryParse(price) ?? 0;
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Color.fromARGB(255, 206, 200, 200),
              color: Colors.black,
            ), // Show loader
          );
        },
      );
      try {
        CollectionReference usersRef = FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(adminPhoneNumber)
            .collection('Users')
            .doc(currentUserPhoneNumber)
            .collection('MoneyCollection');

        DocumentReference passDocRef =
            usersRef.doc(DateFormat('yyyy-MM-dd').format(DateTime.now()));

        // Run a transaction to safely update the passMoney field and create vehicleEntry sub-collection
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(passDocRef);

          if (snapshot.exists) {
            // Cast data to Map<String, dynamic>
            Map<String, dynamic>? data =
                snapshot.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('passMoney')) {
              // Convert the existing passMoney from string to integer
              int existingTotal = int.tryParse(data['passMoney'] ?? '0') ?? 0;
              int newTotal = existingTotal + priceAsInt;

              print('Existing Total: $existingTotal, New Total: $newTotal');

              // Update only the 'passMoney' field without disturbing other fields
              transaction
                  .update(passDocRef, {'passMoney': newTotal.toString()});
            } else {
              // If passMoney field does not exist, create it or update it with the initial amount
              print('Creating document with initial total: $price');
              transaction.set(
                  passDocRef, {'passMoney': price}, SetOptions(merge: true));
            }
          } else {
            // If the document doesn't exist, create it with the initial amount
            print('Creating document with initial total: $price');
            transaction.set(passDocRef, {'passMoney': price});
          }

          // Now we handle the vehicleEntry sub-collection
          CollectionReference vehicleEntryRef =
              passDocRef.collection('vehicleEntry');

          // Check if a document for the vehicle number exists
          QuerySnapshot existingVehicleEntry = await vehicleEntryRef
              .where('vehicleNumber', isEqualTo: _controller.text)
              .get();

          if (existingVehicleEntry.docs.isEmpty) {
            // If no document exists for this vehicle, create a new one
            vehicleEntryRef.add({
              'vehicleNumber': _controller.text,
              'entryTime': DateTime.now(),
              'entryType': 'Pass',
              'selectedTime': selectedRate,
              'selectedRate': price
            });
          } else {
            // If document exists, create a new document with the vehicle details
            vehicleEntryRef.add({
              'vehicleNumber': _controller.text,
              'entryTime': DateTime.now(),
              'entryType': 'Pass',
              'selectedTime': selectedRate,
              'selectedRate': price,
            });
          }
        });
        Navigator.of(context).pop();
        // Navigate to the receipt screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Receipt(
              vehicleNumber: _controller.text,
              rateType: selectedRate,
              price: price,
              page: 'Pass',
            ),
          ),
        );
      } catch (e) {
        print('Error updating total money: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update total money. Please try again.')),
        );
      }
    }
    if (_selectedContainerIndex == null || _controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select price and Enter num.'),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 10, 10, 10),
          duration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 225, 215, 206),
        title: Text(
          'Parking Rates',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: pricingData == null
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 3, 3, 3)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 7, 7, 7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildPricingContainer(
                            context,
                            '1 Month Pass',
                            pricingData!['PassPrice'],
                            0,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '2 Month Pass',
                            (int.tryParse(pricingData!['PassPrice'])! * 2)
                                .toString(),
                            1,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '3 Month Pass',
                            (int.tryParse(pricingData!['PassPrice'])! * 3)
                                .toString(),
                            2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width -
                          48, // Decreases the width by 10 pixels
                      child: TextField(
                        controller: _controller,
                        keyboardType: widget.keyboardtype == 'numeric'
                            ? TextInputType.number
                            : TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Add vehicle number',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black, // Default black border
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Color.fromARGB(255, 207, 239,
                                  1), // Green border when focused
                            ),
                          ),
                          border:
                              const OutlineInputBorder(), // This acts as a fallback border if others are not defined
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 207, 239, 1),
                              Color.fromARGB(255, 1, 1, 1),
                              Color.fromARGB(255, 207, 239, 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 48,
                          height: 70,
                          alignment: Alignment.center,
                          child: Text(
                            'Generate Receipt',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget _buildPricingContainer(
      BuildContext context, String timing, String? price, int index) {
    bool isSelected = _selectedContainerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContainerIndex = index;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 225, 215, 206),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Color.fromARGB(255, 207, 239, 1)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 207, 239, 1)
                      : const Color.fromARGB(165, 250, 249, 248),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/clock.json',
                        height: 23, width: 23),
                    const SizedBox(width: 4),
                    Text(timing),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 50),
              child: Text(
                '₹ ${price ?? 0}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Lottie.asset('assets/animations/line.json', repeat: false),
            ),
          ],
        ),
      ),
    );
  }
}
