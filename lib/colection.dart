import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final String currentUserPhoneNumber = '+919999999999'; // Replace with current user's phone number

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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(currentUserPhoneNumber)
            .collection('Users')
            .doc('+917777777777')
            .collection('Moneycollection')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No money collections found.'));
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var moneyAmount = doc['Money']?.toString() ?? '0';

              return Card(
                elevation: 10.0,
                color: const Color.fromARGB(255, 248, 246, 225), // 3D effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.attach_money,
                    color: Colors.yellow,
                    size: 40,
                  ),
                  title: Text(
                    '₹$moneyAmount',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
