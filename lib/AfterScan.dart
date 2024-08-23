import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    fetchData();
    dueOutTime = formatDateTime(DateTime.now()); // Set the current date and time
  }

  Future<void> fetchData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String phoneNumber = currentUser?.phoneNumber ?? 'unknown';

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('loginUsers')
        .doc(phoneNumber)
        .collection('DueInDetails')
        .doc(widget.vehicleNumber)
        .get();

    if (doc.exists) {
      Timestamp timestamp = doc['timestamp'];
      DateTime dateTime = timestamp.toDate();

      setState(() {
        dueInTime = formatDateTime(dateTime);
        dueInRate = doc['price'] ?? '';
        timeGiven = extractMinutes(doc['selectedTime'] ?? '');

        calculateFinalAmount(dateTime);
      });
    } else {
      print("Document does not exist");
    }
  }

  String extractMinutes(String timeString) {
    // Extract numeric value from "20 minutes" or "30 minutes" etc.
    return timeString.split(" ")[0]; // This will return "20" or "30"
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
                dueInTime,
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
                dueInRate,
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
                "$timeGiven minutes",
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
                dueOutTime,
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
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.yellow.shade700,
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.yellow.shade700, size: 30),
                const SizedBox(width: 8),
                const Text(
                  "Amount to Pay",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Icon(Icons.receipt_long, color: Colors.grey.shade700, size: 28),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_rupee, size: 40, color: Colors.green),
            Text(
              finalAmount,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (timeExceeded)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      "Time Exceeded:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_off_rounded, color: Colors.red.shade300, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exceededTime,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}}
