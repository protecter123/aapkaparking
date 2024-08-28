import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewuser extends StatefulWidget {
  const Viewuser({super.key});

  @override
  State<Viewuser> createState() => _ViewuserState();
}

class _ViewuserState extends State<Viewuser> {
  String? currentUserPhoneNumber;
   @override
  void initState() {
    super.initState();
    _fetchCurrentUserPhoneNumber();
  }
    void _fetchCurrentUserPhoneNumber() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserPhoneNumber = user.phoneNumber;
      });
    }
  }
   // Replace with the actual phone number

  // Method to delete a user document from Firestore
  void _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhoneNumber)
          .collection('Users')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  // Method to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get month name from month number
  String _monthName(int monthNumber) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Users',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(currentUserPhoneNumber)
            .collection('Users')
            .orderBy('CreatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userName = userDoc['userName'] as String;
              final uid = userDoc['uid'] as String;
              final createdAt = userDoc['CreatedAt'] as Timestamp;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(
                    userName,
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        'UID: $uid',
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Created At: ${_formatTimestamp(createdAt)}',
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(userDoc.id),
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
