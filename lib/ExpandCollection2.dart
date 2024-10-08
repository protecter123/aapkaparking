import 'package:aapkaparking/CollectionDetail1.dart';
import 'package:aapkaparking/CollectionDetail2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Expandcollect2 extends StatefulWidget {
  final String userNo; // Pass userNo as argument

  const Expandcollect2({super.key, required this.userNo});

  @override
  State<Expandcollect2> createState() => _ExpandcollectState();
}

class _ExpandcollectState extends State<Expandcollect2> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> moneyCollectionList = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCollectionDetails(); // Fetch initial set of data
    _scrollController.addListener(_scrollListener); // Add scroll listener
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        _fetchCollectionDetails(); // Load more documents when scrolled to the bottom
      }
    }
  }

  // Function to fetch money collection data with pagination and optional date filtering
  Future<List<Map<String, dynamic>>> _fetchCollectionDetails(
      {bool isFiltering = false}) async {
    if (isLoading) return []; // Return an empty list when already loading
    setState(() => isLoading = true);

    final currentUserPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentUserPhone == null) {
      setState(() => isLoading = false);
      return []; // Return an empty list if currentUserPhone is null
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhone)
          .collection('Users')
          .doc(widget.userNo)
          .collection('MoneyCollection')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(10);

      // Apply date filtering if dates are provided
      if (fromDate != null && toDate != null) {
        query = query
            .where(FieldPath.documentId,
                isGreaterThanOrEqualTo:
                    DateFormat('yyyy-MM-dd').format(fromDate!))
            .where(FieldPath.documentId,
                isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(toDate!));
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument =
            querySnapshot.docs.last; // Update the last document for pagination

        final fetchedData = querySnapshot.docs.map((doc) {
          final data = doc.data()
              as Map<String, dynamic>?; // Ensure the data is cast correctly

          return {
            'date': doc.id,
            'dueMoney':
                data?.containsKey('dueMoney') == true ? data!['dueMoney'] : 0,
            'fixMoney':
                data?.containsKey('fixMoney') == true ? data!['fixMoney'] : 0,
            'passMoney':
                data?.containsKey('passMoney') == true ? data!['passMoney'] : 0,
          };
        }).toList();

        setState(() {
          moneyCollectionList.addAll(fetchedData);
        });

        if (querySnapshot.docs.length < 10) {
          setState(() => hasMore = false); // No more documents to fetch
        }

        return fetchedData; // Return fetched data
      } else {
        setState(() => hasMore = false);
        return []; // Return empty list if no documents are fetched
      }
    } catch (e) {
      print('Error fetching data: $e');
      return []; // Return an empty list in case of an error
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 225, 215, 206),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildDateField('From Date', _fromDateController, (pickedDate) {
                  setState(() {
                    fromDate = pickedDate;
                  });
                }),
                const SizedBox(height: 10),
                _buildDateField('To Date', _toDateController, (pickedDate) {
                  setState(() {
                    toDate = pickedDate;
                  });
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fromDateController.clear();
                          _toDateController.clear();
                          fromDate = null;
                          toDate = null;
                          moneyCollectionList.clear();
                          lastDocument = null;
                          hasMore = true;
                        });
                        _fetchCollectionDetails(); // Clear filter and fetch all documents
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (fromDate != null && toDate != null) {
                          setState(() {
                            moneyCollectionList.clear();
                            lastDocument = null;
                            hasMore = true;
                          });
                          _fetchCollectionDetails(
                              isFiltering: true); // Apply date filter
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text('Apply',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      Function(DateTime) onDatePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            focusColor: Colors.orange,
            hintText: 'Select Date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year, DateTime.now().month - 3,
                  DateTime.now().day),
              lastDate: DateTime.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors
                          .orange, // Header background color and selection color
                      onPrimary: Colors.white, // Text color on the header
                      onSurface: Colors.black, // Default text color
                    ),
                    dialogBackgroundColor:
                        Colors.white, // Background color of the dialog
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              onDatePicked(pickedDate);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 225, 215, 206), // Light background color
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar background
        elevation: 0, // Remove AppBar shadow
        centerTitle: true,
        title: Text(
          'Collection Details', // Fixed typo in title
          style: GoogleFonts.nunito(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors
                .black, // Text color to make it visible on a transparent background
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showDateFilterDialog, // Assuming this method is defined
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCollectionDetails(), // Assuming you have this method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error fetching data')); // Error state
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No collections found')); // Empty data state
          }

          final collectionDetails = snapshot.data!;

          return ListView.builder(
            itemCount: collectionDetails.length,
            itemBuilder: (context, index) {
              final collection = collectionDetails[index];
              return _buildCollectionTile(
                  collection); // Custom widget for each item
            },
          );
        },
      ),
    );
  }

  // Build the collection tile with modern design
  Widget _buildCollectionTile(Map<String, dynamic> collection) {
    // Parse the date from the 'collection' map and format it
    final DateTime parsedDate = DateTime.parse(collection['date']);
    final String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background
          border:
              Border.all(color: Colors.black, width: 1), // 1 px black border
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
                      const SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Collection on $formattedDate', // Use formatted date here
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
                      const SizedBox(width: 8), // Space between icon and text
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
                      _buildMoneyContainer(
                          'Fix',
                          collection['fixMoney'],
                          Colors.green,
                          Icons.attach_money,
                          collection['date'],
                          widget.userNo,
                          context),
                      _buildMoneyContainer(
                          'Due',
                          collection['dueMoney'],
                          Colors.red,
                          Icons.money_off,
                          collection['date'],
                          widget.userNo,
                          context),
                      _buildMoneyContainer(
                          'Pass',
                          collection['passMoney'],
                          Colors.blue,
                          Icons.money,
                          collection['date'],
                          widget.userNo,
                          context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create colorful money containers
  Widget _buildMoneyContainer(String title, dynamic amount, Color color,
      IconData icon, String date, String usernum, BuildContext context) {
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
        } else {
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
          borderRadius:
              BorderRadius.circular(10), // Rounded corners for modern look
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
