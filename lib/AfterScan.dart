import 'dart:math';

import 'package:aapkaparking/bluetoothManager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfterScan extends StatefulWidget {
  final String vehicleNumber;

  const AfterScan({super.key, required this.vehicleNumber});

  @override
  State<AfterScan> createState() => _AfterScanState();
}

class _AfterScanState extends State<AfterScan> {
  String dueInTime = "";
  String dueInRate = "";
  String timeGiven = "";
  String dueOutTime = "";
  bool timeExceeded = false;
  String exceededTime = "";
  String finalAmount = "";
  BluetoothManager bluetoothManager = BluetoothManager();

  @override
  void initState() {
    super.initState();
    fetchData();
    dueOutTime = formatDateTime(DateTime.now());
  }
 void saveData() async {
  try {
    // Retrieve adminPhoneNumber from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminPhoneNumber = prefs.getString('AdminNum');

    // If adminPhoneNumber is null, throw an error or handle it accordingly
    if (adminPhoneNumber == null) {
      print('Error: Admin phone number is missing');
      return;
    }

    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUserPhoneNumber = currentUser?.phoneNumber ?? 'unknown';

    // Format today's date as yyyy-MM-dd
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Reference to the MoneyCollection -> Today's Date -> vehicleEntry subcollection
    CollectionReference vehicleEntryRef = FirebaseFirestore.instance
        .collection('AllUsers')
        .doc(adminPhoneNumber)
        .collection('Users')
        .doc(currentUserPhoneNumber)
        .collection('MoneyCollection')
        .doc(formattedDate) // Document for today's date
        .collection('vehicleEntry');

    // Generate a random document ID for this entry
    String docId = Random().nextInt(1000000).toString();

    // Data to save
    Map<String, dynamic> dataToSave = {
      'type': 'Due',
      'dueInTime': dueInTime,
      'dueOutTime': dueOutTime,
      'dueInRate': dueInRate,
      'timeGiven': timeGiven,
      'exceededTime': timeExceeded ? exceededTime : '0', // If timeExceeded is false, save 0
      'finalAmount': finalAmount,
      'vehicleNumber':widget.vehicleNumber 
    };

    // Save the data to the vehicleEntry subcollection
    await vehicleEntryRef.doc(docId).set(dataToSave);

    print('Data saved successfully to Firestore');
  } catch (e) {
    print('Error saving data: $e');
  }
}
  Future<void> fetchData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String phoneNumber = currentUser?.phoneNumber ?? 'unknown';

      // Perform the query to find documents with the matching vehicle number
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('LoginUsers')
              .doc(phoneNumber)
              .collection('DueInDetails')
              .doc(DateTime.now().year.toString())
              .collection(DateTime.now().month.toString())
              .where('vehicleNumber', isEqualTo: widget.vehicleNumber)
              .orderBy('timestamp', descending: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the current time
        DateTime now = DateTime.now();

        // Sort documents by the absolute difference between their timestamp and the current time
        querySnapshot.docs.sort((a, b) {
          DateTime timeA = (a.data()['timestamp'] as Timestamp).toDate();
          DateTime timeB = (b.data()['timestamp'] as Timestamp).toDate();

          // Calculate the difference in time between the document's timestamp and now
          int differenceA = (now.difference(timeA)).abs().inMilliseconds;
          int differenceB = (now.difference(timeB)).abs().inMilliseconds;

          return differenceA
              .compareTo(differenceB); // Smallest difference first
        });

        // Select the document with the smallest difference (closest to now)
        QueryDocumentSnapshot<Map<String, dynamic>> doc =
            querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data();

        Timestamp timestamp = data['timestamp'] as Timestamp;
        DateTime dateTime = timestamp.toDate();

        setState(() {
          dueInTime = formatDateTime(dateTime);
          dueInRate = data['price']?.toString() ?? '';
          timeGiven = extractMinutes(data['selectedTime']?.toString() ?? '');

          calculateFinalAmount(dateTime);
        });

        // After fetching all details, start printing the receipt
        saveData();
        await printReceipt();
      } else {
        print("No documents found for the given vehicle number.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  String extractMinutes(String timeString) {
    return timeString.split(" ")[0];
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  void calculateFinalAmount(DateTime dueInDateTime) {
    DateTime dueOutDateTime = DateTime.now();
    Duration difference = dueOutDateTime.difference(dueInDateTime);

    int givenTimeInMinutes = int.parse(timeGiven);
    int differenceInMinutes = difference.inMinutes;

    if (differenceInMinutes > givenTimeInMinutes) {
      timeExceeded = true;
      int exceededMinutes = differenceInMinutes - givenTimeInMinutes;
      exceededTime =
          "${(exceededMinutes / 60).floor()} hours and ${exceededMinutes % 60} minutes";

      int dueInRateValue = int.parse(dueInRate);
      int additionalCharges = (exceededMinutes / 60).floor() * dueInRateValue;
      finalAmount = "${dueInRateValue + additionalCharges}";
    } else {
      timeExceeded = false;
      finalAmount = dueInRate;
    }

    setState(() {});
  }

  Future<void> printReceipt() async {
    
      final printer = bluetoothManager.printer;

      // Printing Receipt Header
      printer.printNewLine();
      printer.printCustom(
          'Receipt Details', 2, 1); // 2: Font size, 1: Center aligned
      printer.printNewLine();

      // Printing Due In details
      printer.printCustom(
          "Due In", 1, 0); // 1: Normal font size, 0: Left aligned
      printer.printNewLine();
      printer.printCustom("Vehicle No.: ${widget.vehicleNumber}", 1, 0);
      printer.printCustom("Due In Time: $dueInTime", 1, 0);
      printer.printCustom("Due In Rate: ₹$dueInRate", 1, 0);
      printer.printCustom("Time Given: $timeGiven minutes", 1, 0);
      printer.printNewLine();

      // Printing Due Out details
      printer.printCustom(
          "Due Out", 1, 0); // 1: Normal font size, 0: Left aligned
      printer.printNewLine();
      printer.printCustom("Current Time: $dueOutTime", 1, 0);
      printer.printNewLine();

      // Printing Final Amount
      printer.printCustom(
          "Amount to Pay", 2, 1); // 2: Font size, 1: Center aligned
      printer.printNewLine();
      printer.printCustom("Rs$finalAmount", 2,
          1); // Centered and larger font for the final amount
      if (timeExceeded) {
        printer.printNewLine();
        printer.printCustom("Time Exceeded: $exceededTime", 1, 0);
      }
      printer.printNewLine();

      // Printing Footer
      printer.printCustom('Thank you, Lucky Road!', 1, 1);
      printer.printNewLine();
      printer.paperCut(); // Cut the paper after printing
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text("Summary of ${widget.vehicleNumber}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDueInContainer(),
            const SizedBox(height: 16),
            buildDueOutContainer(),
            const SizedBox(height: 16),
            buildFinalAmountContainer(),
          ],
        ),
      ),
    );
  }

  Widget buildDueInContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Due In",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.vehicleNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                "Due In Time: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                dueInTime.isNotEmpty
                    ? dueInTime
                    : 'Loading...', // Default text while loading
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                "Due In Rate: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                dueInRate.isNotEmpty
                    ? dueInRate
                    : 'Loading...', // Default text while loading
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                "Time Given: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                timeGiven.isNotEmpty
                    ? "$timeGiven minutes"
                    : 'Loading...', // Default text while loading
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDueOutContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Due Out",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.vehicleNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                "Current Time: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                dueOutTime.isNotEmpty
                    ? dueOutTime
                    : 'Loading...', // Default text while loading
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFinalAmountContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amount to Pay",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                "Final Amount: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "₹$finalAmount",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (timeExceeded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  "Time Exceeded: ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  exceededTime,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
