import 'package:aapkaparking/bluetoothManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Get the admin's phone number from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminPhoneNumber = prefs.getString('AdminNum');

      if (adminPhoneNumber == null) {
        // Handle the case where the admin phone number is not available
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Reference to the AllUsers collection
      DocumentReference adminDocRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(adminPhoneNumber);

      // Fetch the admin document
      DocumentSnapshot adminDoc = await adminDocRef.get();

      if (adminDoc.exists) {
        // Extract parking name and logo from the admin's document
        Map<String, dynamic> adminData =
            adminDoc.data() as Map<String, dynamic>;

        setState(() {
          parkingLogo = adminData['ParkingLogo'] ?? '';
          parkingName = adminData['ParkingName'] ?? 'Parking Name';
          isLoading = false;
        });

        // Call printReceipt to print the receipt
        printReceipt();
      } else {
        // If admin document doesn't exist
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> printReceipt() async {
    final printer = bluetoothManager.printer;

    printer.printNewLine();
    printer.printCustom('${widget.page} Receipt Details', 4, 1);
    printer.printNewLine();

    printer.printCustom(parkingName, 4, 1);
    printer.printNewLine();

    String dateTime =
        'DATE: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}, Time: ${DateFormat('hh:mm a').format(DateTime.now())}';
    printer.printCustom(dateTime, 1, 1);
    printer.printNewLine();

    printer.printCustom('Vehicle No.: ${widget.vehicleNumber}', 2, 1);
    printer.printCustom('Amount: Rs :${widget.price}', 2, 1);
    printer.printNewLine();

    printer.printQRcode(widget.vehicleNumber, 400, 400, 1);
    printer.printNewLine();

    printer.printCustom('Thank you, Lucky Road!', 1, 1);
    printer.printNewLine();
    printer.paperCut();
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
                            'DATE: ${DateFormat('dd MMM yyyy').format(DateTime.now())}, Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
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
