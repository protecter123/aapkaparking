import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reciept.dart';

class Fixirate extends StatefulWidget {
  final String imgUrl;
  final String keyboardtype;

  const Fixirate({super.key, required this.imgUrl, required this.keyboardtype});

  @override
  _FixirateState createState() => _FixirateState();
}

class _FixirateState extends State<Fixirate> {
  int? _selectedContainerIndex;
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? pricingData;
  String adminPhoneNumber = '';
  String currentUserPhoneNumber = '';
  Future<void> fetchPricingDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserPhoneNumber = currentUser?.phoneNumber ?? 'unknown';

    try {
      // Reference to the AllUsers collection
      CollectionReference allUsersRef =
          FirebaseFirestore.instance.collection('AllUsers');

      // Fetch all admin documents
      QuerySnapshot adminsSnapshot = await allUsersRef.get();

      for (QueryDocumentSnapshot adminDoc in adminsSnapshot.docs) {
        // Reference to the Users subcollection
        CollectionReference usersRef = adminDoc.reference.collection('Users');

        // Check if the current user's phone number exists in this admin's Users subcollection
        DocumentSnapshot userDoc =
            await usersRef.doc(currentUserPhoneNumber).get();

        if (userDoc.exists) {
          // Set admin phone number and update the vehiclesCollection reference
          adminPhoneNumber = adminDoc.id;
          SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('AdminNum', adminPhoneNumber); // Admin phone number or document ID
          CollectionReference vehiclesCollection =
              adminDoc.reference.collection('Vehicles');

          // Fetch pricing details based on the vehicle image URL
          var snapshot = await vehiclesCollection
              .where('vehicleImage', isEqualTo: widget.imgUrl)
              .get();

          if (snapshot.docs.isNotEmpty) {
            setState(() {
              pricingData = snapshot.docs.first.data() as Map<String, dynamic>;
            });
          }
          return; // Exit the loop once the correct admin is found
        }
      }

      // Handle the case where no matching admin is found
      setState(() {
        pricingData = null;
      });
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
          ? '30 Minutes'
          : _selectedContainerIndex == 1
              ? '60 Minutes'
              : '120 Minutes';

      var price = _selectedContainerIndex == 0
          ? pricingData!['Pricing30Minutes']
          : _selectedContainerIndex == 1
              ? pricingData!['Pricing1Hour']
              : pricingData!['Pricing120Minutes'];

      // Convert price to double
      num priceAsDouble = num.tryParse(price.toString()) ?? 0.0;

      // Firestore update logic
      try {
        CollectionReference usersRef = FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(adminPhoneNumber)
            .collection('Users')
            .doc(currentUserPhoneNumber)
            .collection('MoneyCollection');

        DocumentReference fixDocRef =
            usersRef.doc(DateFormat('yyyy-MM-dd').format(DateTime.now()));

        // Run a transaction to safely update the fixMoney field and create vehicleEntry sub-collection
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(fixDocRef);

          if (snapshot.exists) {
            // Cast data to Map<String, dynamic>
            Map<String, dynamic>? data =
                snapshot.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('fixMoney')) {
              // Convert the existing fixMoney from string to double
              num existingTotal =
                  int.tryParse(data['fixMoney'] ?? '0.0') ?? 0.0;
              num newTotal = existingTotal + priceAsDouble;

              print('Existing Total: $existingTotal, New Total: $newTotal');

              // Update only the 'fixMoney' field without disturbing other fields
              transaction.update(fixDocRef, {'fixMoney': newTotal.toString()});
            } else {
              // If fixMoney field does not exist, create it or update it with the initial amount
              print('Creating document with initial total: $priceAsDouble');
              transaction.set(fixDocRef, {'fixMoney': priceAsDouble.toString()},
                  SetOptions(merge: true));
            }
          } else {
            // If the document doesn't exist, create it with the initial amount
            print('Creating document with initial total: $priceAsDouble');
            transaction.set(fixDocRef, {'fixMoney': priceAsDouble.toString()});
          }

          // Now we handle the vehicleEntry sub-collection
          CollectionReference vehicleEntryRef =
              fixDocRef.collection('vehicleEntry');

          // Check if a document for the vehicle number exists
          QuerySnapshot existingVehicleEntry = await vehicleEntryRef
              .where('vehicleNumber', isEqualTo: _controller.text)
              .get();

          if (existingVehicleEntry.docs.isEmpty) {
            // If no document exists for this vehicle, create a new one
            vehicleEntryRef.add({
              'vehicleNumber': _controller.text,
              'entryTime': DateTime.now(),
              'entryType': 'Fix',
              'selectedTime': selectedRate,
              'selectedRate': price,
            });
          } else {
            // If document exists, create a new document with the vehicle details
            vehicleEntryRef.add({
              'vehicleNumber': _controller.text,
              'entryTime': DateTime.now(),
              'entryType': 'Fix',
              'selectedTime': selectedRate,
              'selectedRate': price,
            });
          }
        });

        // Navigate to the receipt screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Receipt(
              vehicleNumber: _controller.text,
              rateType: selectedRate,
              price: priceAsDouble.toString(),
              page: 'Fix',
            ),
          ),
        );
      } catch (e) {
        print('Error updating total money: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update total money. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Parking Rates',
              textStyle: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 200),
            ),
          ],
          isRepeatingAnimation: true,
          repeatForever: true,
        ),
        centerTitle: true,
      ),
      body: pricingData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildPricingContainer(
                            context,
                            '30 Minutes',
                            int.tryParse(
                                pricingData!['Pricing30Minutes'] ?? '0'),
                            0,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '60 Minutes',
                            int.tryParse(pricingData!['Pricing1Hour'] ?? '0'),
                            1,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '120 Minutes',
                            int.tryParse(
                                pricingData!['Pricing120Minutes'] ?? '0'),
                            2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width -
                          48, // Decreases the width by 10 pixels
                      child: TextField(
                        controller: _controller,
                        keyboardType: widget.keyboardtype == 'numeric'
                            ? TextInputType.number
                            : TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Add vehicle number',
                          border: OutlineInputBorder(),
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
                              Color.fromARGB(255, 231, 242, 136),
                              Color.fromARGB(255, 77, 50, 80)
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
      BuildContext context, String timing, int? price, int index) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 1,
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
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
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
              padding: EdgeInsets.only(top: 50.0),
              child: Lottie.asset('assets/animations/line.json', repeat: false),
            ),
          ],
        ),
      ),
    );
  }
}
