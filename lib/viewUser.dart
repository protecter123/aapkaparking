import 'dart:async';
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
  String searchQuery = '';
  List<DocumentSnapshot> filteredUsers = [];
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

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

  void _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhoneNumber)
          .collection('Users')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int monthNumber) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[monthNumber - 1];
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query.toLowerCase();
      });
    });
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 225, 215, 206),
          title: const Text(
            'Delete User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without deleting
              },
              child: const Text('No', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(userId); // Call the delete function
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      appBar: AppBar(
        title: const Text(
          'All Users',
          style: TextStyle(
            fontFamily: 'baskerville',
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(0, 255, 235, 59),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search user by full name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text == ''
                    ? IconButton(
                        icon: const Icon(Icons.keyboard),
                        onPressed: () {
                          _searchController.clear();

                          FocusScope.of(context).unfocus();
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          FocusScope.of(context).unfocus();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                final displayedUsers = searchQuery.isEmpty
                    ? users
                    : users.where((user) {
                        final userName =
                            (user['userName'] as String).toLowerCase();
                        final searchWords = searchQuery
                            .split(' ')
                            .where((word) => word.isNotEmpty)
                            .toList();
                        return searchWords
                            .every((word) => userName.contains(word));
                      }).toList();

                return ListView.builder(
                  itemCount: displayedUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = displayedUsers[index];
                    final userName = userDoc['userName'] as String;
                    final uid = userDoc['uid'] as String;
                    final createdAt = userDoc['CreatedAt'] as Timestamp;

                    return Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 225, 215, 206),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            title: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.black),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    userName.toUpperCase(),
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Phone no.: $uid',
                                      style: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 57, 57, 57)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Joined At: ${_formatTimestamp(createdAt)}',
                                      style: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 57, 57, 57)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteDialog(context, userDoc.id);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
