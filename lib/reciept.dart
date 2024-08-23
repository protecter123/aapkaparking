import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receipt extends StatefulWidget {
  final String vehicleNumber;
  final String rateType;
  final String price;
  

  const Receipt({
    super.key,
    required this.vehicleNumber,
    required this.rateType,
    required this.price,
  });

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final DateFormat formatter = DateFormat('HH:mm:ss');
  String parkingLogo = '';
  String parkingName = '';
  bool isLoading = true;
  bool _isConnected=true;
  FlutterBluePlus bluetooth = FlutterBluePlus();
  @override
  void initState() {
    super.initState();
    fetchParkingDetails();
  }
 Future<void> printReceipt() async {
  if (_isConnected) {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Logo
      //  if (parkingLogo.isNotEmpty) {
      //   final ByteData logoBytes = await NetworkAssetBundle(Uri.parse(parkingLogo)).load("");
      //   final Uint8List logo = logoBytes.buffer.asUint8List();
      //   // Make sure the logo is in a supported format (e.g., PNG)
      //   // Example code to process image if needed (conversion, resizing, etc.)
      //   bytes += generator.imageRaster(logo); 
      // }

      // Parking Name
      bytes += generator.text(parkingName,
          styles: PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size2,
              width: PosTextSize.size2));

      // Yellow Line
      bytes += generator.hr();

      // Paid Parking Text
      bytes += generator.text('Paid Parking',
          styles: PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size2));

      // Date and Time
      final formatter = DateFormat('dd-MM-yyyy, HH:mm'); // Define your DateFormat
      bytes += generator.text(
          'DATE: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}, Time: ${formatter.format(DateTime.now())}',
          styles: PosStyles(
              align: PosAlign.center,
              bold: false));

      // Vehicle Number
      bytes += generator.text('Vehicle No.: ${widget.vehicleNumber}',
          styles: PosStyles(
              align: PosAlign.center,
              bold: true));

      // Amount
      bytes += generator.text('Amount: ₹${widget.price}',
          styles: PosStyles(
              align: PosAlign.center,
              bold: true));

      // QR Code
      bytes += generator.qrcode(widget.vehicleNumber, size: QRSize.Size8);

      // Yellow Line
      bytes += generator.hr();

      // Thank You Note
      bytes += generator.text('Thank you, Lucky Road!',
          styles: PosStyles(
              align: PosAlign.center,
              bold: true));

      // Cut the paper
      bytes += generator.cut();

      // Write bytes to Bluetooth printer
     // Uint8List byteData = Uint8List.fromList(bytes);

      // Send data to the printer
     // await bluetooth.writeBytes(byteData);
    } catch (e) {
      print("Error while printing receipt: $e");
    }
  } else {
    print("Printer not connected");
  }
}

  Future<void> fetchParkingDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('AllUsers')
          .doc('+919999999999')
          .get();

      setState(() {
        parkingLogo = snapshot.data()?['ParkingLogo'] ?? '';
        parkingName = snapshot.data()?['ParkingName'] ?? 'Parking Name';
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow, // Yellow AppBar
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
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow,))
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
                          // Logo and Parking Area Name
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
                          // Yellow Line
                          Container(
                            height: 2,
                            color: Colors.yellow,
                          ),
                          // Paid Parking Text
                          Text(
                            'Paid Parking',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Date
                          Text(
                            'DATE: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}, Time: ${formatter.format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Vehicle Number and Rate
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
                          // QR Code
                          QrImageView(
                            data: widget.vehicleNumber,
                            size: constraints.maxHeight * 0.3,
                            backgroundColor: Colors.white,
                          ),
                          // Yellow Line
                          Container(
                            height: 2,
                            color: Colors.yellow,
                          ),
                          // Thank You and Lucky Road
                          const Text(
                            'Thank you , Lucky Road!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Generate Receipt Button
                          ElevatedButton(
                            onPressed: () {
                              printReceipt();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Print Receipt',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
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
