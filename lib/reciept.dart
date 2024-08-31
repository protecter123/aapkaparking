import 'package:aapkaparking/bluetoothManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class Receipt extends StatefulWidget {
  final String vehicleNumber;
  final String rateType;
  final String price;
  final String page;

  const Receipt({
    super.key,
    required this.vehicleNumber,
    required this.rateType,
    required this.price,
    required this.page,
  });

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final DateFormat formatter = DateFormat('HH:mm:ss');
  String parkingLogo = '';
  String parkingName = '';
  bool isLoading = true;
  BluetoothManager bluetoothManager = BluetoothManager();

  @override
  void initState() {
    super.initState();
    findAdminAndFetchParkingDetails();
  }

  Future<void> findAdminAndFetchParkingDetails() async {
    try {
      // Get the current user's phone number from Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.phoneNumber == null) {
        // Handle the case where the user is not logged in or phone number is not available
        setState(() {
          isLoading = false;
        });
        return;
      }
      String currentPhoneNumber = currentUser.phoneNumber!;

      // Reference to the AllUsers collection
      CollectionReference allUsersRef =
          FirebaseFirestore.instance.collection('AllUsers');

      // Fetch all admin documents
      QuerySnapshot adminsSnapshot = await allUsersRef.get();

      for (QueryDocumentSnapshot adminDoc in adminsSnapshot.docs) {
        // Reference to the Users subcollection
        CollectionReference usersRef = adminDoc.reference.collection('Users');

        // Check if the current user's phone number exists in this admin's Users subcollection
        DocumentSnapshot userDoc = await usersRef.doc(currentPhoneNumber).get();

        if (userDoc.exists) {
          // If the user document exists, fetch the parking details
          setState(() {
            // Explicitly cast adminDoc.data() to Map<String, dynamic>
            Map<String, dynamic> adminData =
                adminDoc.data() as Map<String, dynamic>;

            parkingLogo = adminData['ParkingLogo'] ?? '';
            parkingName = adminData['ParkingName'] ?? 'Parking Name';
            isLoading = false;
          });

          return;
        }
      }

      // If no matching admin is found, stop loading and handle the error case
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> printReceipt() async {
    if (bluetoothManager.isConnected()) {
      final printer = bluetoothManager.printer;

      printer.printNewLine();
      printer.printCustom('Receipt Details', 2, 1);
      printer.printNewLine();

      printer.printCustom(parkingName, 3, 1);
      printer.printNewLine();

      String dateTime =
          'DATE: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}, Time: ${formatter.format(DateTime.now())}';
      printer.printCustom(dateTime, 1, 1);
      printer.printNewLine();

      printer.printCustom('Vehicle No.: ${widget.vehicleNumber}', 2, 1);
      printer.printCustom('Amount: ₹${widget.price}', 2, 1);
      printer.printNewLine();

      printer.printCustom('QR Code: ${widget.vehicleNumber}', 1, 1);
      printer.printNewLine();

      printer.printCustom('Thank you, Lucky Road!', 1, 1);
      printer.printNewLine();
      printer.paperCut();
    } else {
      print('No printer connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Receipt Details',
          style: GoogleFonts.nunito(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.yellow,
            ))
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Image.network(
                                parkingLogo,
                                height: constraints.maxHeight * 0.15,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                parkingName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.yellow,
                          ),
                          Text(
                            'Paid Parking',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'DATE: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}, Time: ${formatter.format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Column(
                            children: [
                              Text(
                                'Vehicle No.: ${widget.vehicleNumber}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Amount: ₹${widget.price}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          QrImageView(
                            data: widget.vehicleNumber,
                            size: constraints.maxHeight * 0.3,
                            backgroundColor: Colors.white,
                          ),
                          Container(
                            height: 2,
                            color: Colors.yellow,
                          ),
                          const Text(
                            'Thank you, Lucky Road!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
