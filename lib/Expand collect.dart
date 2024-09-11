import 'package:aapkaparking/CollectionDetail1.dart';
import 'package:aapkaparking/CollectionDetail2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Expandcollect extends StatefulWidget {
  final String userNo; // Pass userNo as argument

  const Expandcollect({super.key, required this.userNo});

  @override
  State<Expandcollect> createState() => _ExpandcollectState();
}

class _ExpandcollectState extends State<Expandcollect> {
  // Function to fetch money collection data from Firestore
  Future<List<Map<String, dynamic>>> _fetchCollectionDetails() async {
    final currentUserPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentUserPhone == null) {
      return [];
    }

    List<Map<String, dynamic>> moneyCollectionList = [];

    try {
      // Accessing the Firestore data based on the path described
      final usersDoc = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhone)
          .collection('Users')
          .doc(widget.userNo)
          .collection('MoneyCollection');

      // Ensure no limit is applied by using get() without any restrictions
      final querySnapshot = await usersDoc.get();

      // Extract data from each document
      for (var doc in querySnapshot.docs) {
        print('Fetched Document ID: ${doc.id}, Data: ${doc.data()}');

        // Assign default value of 0 if any of the fields are missing
        moneyCollectionList.add({
          'date': doc.id,
          'dueMoney': doc.data().containsKey('dueMoney') ? doc['dueMoney'] : 0,
          'fixMoney': doc.data().containsKey('fixMoney') ? doc['fixMoney'] : 0,
          'passMoney':
              doc.data().containsKey('passMoney') ? doc['passMoney'] : 0,
        });
      }

      // Log the total number of documents fetched
      print('Total documents fetched: ${moneyCollectionList.length}');
    } catch (e) {
      // Catching and logging any potential error
      print('Error fetching data: $e');
    }

    return moneyCollectionList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        centerTitle: true,
        title: Text(
          'Collection Details',
          style: GoogleFonts.nunito(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCollectionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No collections found'));
          }

          final collectionDetails = snapshot.data!;

          return ListView.builder(
            itemCount: collectionDetails.length,
            itemBuilder: (context, index) {
              final collection = collectionDetails[index];
              return _buildCollectionTile(collection);
            },
          );
        },
      ),
    );
  }

  // Build the collection tile with modern design
  Widget _buildCollectionTile(Map<String, dynamic> collection) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent background
              border: Border.all(
                  color: Colors.black, width: 1), // 1 px black border
              borderRadius:
                  BorderRadius.circular(10), // Rectangular with slight curve
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for date with icon
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: Colors.black), // Icon for date
                          const SizedBox(
                              width: 8), // Space between icon and text
                          Text(
                            'Collection on ${collection['date']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // Modern UI text color
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 8), // Space between date and user number
                      // Row for user number with icon
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 20,
                              color: Colors.black), // Icon for user number
                          const SizedBox(
                              width: 8), // Space between icon and text
                          Text(
                            'User No: ${widget.userNo}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54, // Subtle text color
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 20), // Increased height between elements
                      // Row for money containers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMoneyContainer('Fix', collection['fixMoney'],
                              Colors.green, Icons.attach_money,collection['date'],widget.userNo,context
                              ),
                          _buildMoneyContainer('Due', collection['dueMoney'],
                              Colors.red, Icons.money_off,collection['date'],widget.userNo,context),
                          _buildMoneyContainer('Pass', collection['passMoney'],
                              Colors.blue, Icons.money,collection['date'],widget.userNo,context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  // Helper function to create colorful money containers
  Widget _buildMoneyContainer(
    String title, dynamic amount, Color color, IconData icon, String date, String usernum, BuildContext context) {
  return GestureDetector(
    onTap: () {
      if (title == "Fix" || title == "Pass") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetails1(
              title: title,
              date: date,
              usernum: usernum,
            ),
          ),
        );
      }
      else{
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetail2(
              title: title,
              date: date,
              usernum: usernum,
            ),
          ),
        );
      }
    },
    child: Container(
      height: 80, // Slightly increased height for better spacing
      width: 100, // Increased width for better alignment
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Light transparent background color
        border: Border.all(color: Colors.black), // Black border
        borderRadius: BorderRadius.circular(10), // Rounded corners for modern look
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5), // Space between icon and text
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16, // Increased font size for title
            ),
          ),
          const SizedBox(height: 5),
          Text(
            amount.toString(),
            style: TextStyle(
              fontSize: 18, // Slightly increased font size for amount
              color: color,
              fontWeight: FontWeight.bold, // Bold amount text
            ),
          ),
        ],
      ),
    ),
  );
}

}
