import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final String currentUserPhoneNumber = '+919999999999'; // Replace with the current user's phone number
  final String selectedUserPhoneNumber = '+917777777777'; // Replace with the selected user's phone number

  Future<Map<String, dynamic>> fetchMoneyCollectionData() async {
    // Fetch user document
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
        .collection('AllUsers')
        .doc(currentUserPhoneNumber)
        .collection('Users')
        .doc(selectedUserPhoneNumber)
        .get();

    if (userDoc.exists) {
      // Fetch totalMoney from MoneyCollection subcollection
      Map<String, dynamic> totalMoney = {};
      var moneyCollectionDocs = await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhoneNumber)
          .collection('Users')
          .doc(selectedUserPhoneNumber)
          .collection('MoneyCollection')
          .get();

      for (var doc in moneyCollectionDocs.docs) {
        var docData = doc.data();
        if (docData != null) {
          totalMoney[doc.id] = docData['totalMoney']?.toString() ?? '0';
        }
      }

      return {
        'userName': userDoc.data()?['userName'] ?? 'Unknown User',
        'uid': userDoc.data()?['uid'] ?? 'Unknown UID',
        ...totalMoney,
      };
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          'Money Collection',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMoneyCollectionData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No money collections found.'));
          }

          var userData = snapshot.data!;
          var userName = userData['userName'] ?? 'Unknown User';
          var userUID = userData['uid'] ?? 'Unknown UID';
          var fixMoney = userData['Fix'] ?? '0';
          var dueMoney = userData['Due'] ?? '0';
          var passMoney = userData['Pass'] ?? '0';

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(255, 248, 246, 225), // 3D effect
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Name and UID
                    Text(
                      userName,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'UID: $userUID',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Money Containers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildMoneyCard('Fix', fixMoney, Colors.green)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMoneyCard('Due', dueMoney, Colors.orange)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMoneyCard('Pass', passMoney, Colors.blue)),
                      ],
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

  Widget _buildMoneyCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹$amount',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
