import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FpList extends StatefulWidget {
  final String label;

  const FpList({super.key, required this.label});

  @override
  State<FpList> createState() => _FpListState();
}

class _FpListState extends State<FpList> {
  String? adminNum;
  String? userPhoneNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allEntries = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredEntries = [];
  bool isLoading = false;
  bool hasMoreData = true;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument; // For pagination
  final int pageSize = 5; // Fetch 5 documents at a time
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getUserPhoneNumber();
    _getAdminNum();
    _scrollController.addListener(_onScroll); // Listen for scroll to bottom
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose search controller when done
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query.toLowerCase();
        _filterEntriesBySearchQuery();
      });
    });
  }

  void _filterEntriesBySearchQuery() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredEntries =
            List.from(allEntries); // Copy all entries to filtered list
      } else {
        filteredEntries = allEntries.where((entry) {
          final vehicleNumber =
              (entry['vehicleNumber'] ?? '').toString().toLowerCase();
          return vehicleNumber.contains(searchQuery);
        }).toList();
      }
    });
  }

  // Fetch the admin number from shared preferences
  Future<void> _getAdminNum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminNum = prefs.getString('AdminNum');
      debugPrint('AdminNum fetched: $adminNum');
      _fetchVehicleData(); // Fetch initial data after adminNum is loaded
    });
  }

  // Fetch the current user's phone number from Firebase Auth
  void _getUserPhoneNumber() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userPhoneNumber = user.phoneNumber;
        debugPrint('User phone number fetched: $userPhoneNumber');
      });
    }
  }

  // Fetch the vehicle entry data with pagination
  Future<void> _fetchVehicleData() async {
    if (isLoading || !hasMoreData) return;
    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 5));

      if (adminNum != null && userPhoneNumber != null) {
        Query<Map<String, dynamic>> query = FirebaseFirestore.instance
            .collection('AllUsers')
            .doc(adminNum)
            .collection('Users')
            .doc(userPhoneNumber)
            .collection('MoneyCollection')
            .where('__name__',
                isGreaterThanOrEqualTo:
                    DateFormat('yyyy-MM-dd').format(fiveDaysAgo))
            .where('__name__',
                isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now))
            .limit(pageSize);

        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument!); // Pagination logic
        }

        QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          // Reverse the order of dates fetched from 'MoneyCollection'
          final reversedDocs = snapshot.docs.reversed.toList();
          lastDocument =
              reversedDocs.last; // Update last document for pagination

          for (var doc in reversedDocs) {
            QuerySnapshot<Map<String, dynamic>> vehicleEntries =
                await FirebaseFirestore.instance
                    .collection('AllUsers')
                    .doc(adminNum)
                    .collection('Users')
                    .doc(userPhoneNumber)
                    .collection('MoneyCollection')
                    .doc(doc.id)
                    .collection('vehicleEntry')
                    .where('entryType', isEqualTo: widget.label)
                    .orderBy('entryTime', descending: true)
                    .get();

            // Reverse the vehicle entries and add to the list
            allEntries.addAll(vehicleEntries.docs.reversed);
            _filterEntriesBySearchQuery(); // Re-filter data after each load
          }

          if (snapshot.docs.length < pageSize) {
            hasMoreData = false; // No more data to fetch
          }
        } else {
          hasMoreData = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching vehicle data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load more data when user scrolls to the bottom
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchVehicleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4.0,
        centerTitle: true,
        title: Text(
          '${widget.label} Entries',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
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
                labelText: 'Search by vehicle number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
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
          adminNum == null || userPhoneNumber == null
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.black,
                ))
              : Expanded(
                  child: filteredEntries.isEmpty && isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.black,
                        ))
                      : ListView.builder(
                          controller:
                              _scrollController, // Attach scroll controller
                          itemCount:
                              filteredEntries.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredEntries.length) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.black,
                                )),
                              ); // Loading indicator at the end
                            }

                            final doc = filteredEntries[index];
                            final vehicleNumber =
                                doc['vehicleNumber'] ?? 'No Vehicle Number';
                            final selectedTime =
                                doc['selectedTime'] ?? 'No Selected Time';
                            final entryTime =
                                (doc['entryTime'] as Timestamp).toDate();

                            return GestureDetector(
                              onTap: () {
                                // Handle tap if needed
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_car,
                                            color: Colors.yellow),
                                        const SizedBox(width: 8),
                                        Text(
                                          vehicleNumber,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Selected Time: $selectedTime',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('d MMM yyyy')
                                              .format(entryTime),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          DateFormat('h:mm a')
                                              .format(entryTime),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
