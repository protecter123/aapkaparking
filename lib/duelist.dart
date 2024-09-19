import 'package:aapkaparking/AfterScan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For debounce logic

class Duelist extends StatefulWidget {
  const Duelist({super.key});

  @override
  State<Duelist> createState() => _DuelistState();
}

class _DuelistState extends State<Duelist> {
  String? userPhoneNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int _limit = 10; // Number of documents to fetch per page
  DocumentSnapshot?
      _lastDocument; // Keeps track of the last document for pagination
  bool _isLoadingMore = false; // Whether more data is being loaded
  bool _hasMoreData = true; // Whether more data is available to load
  final ScrollController _scrollController = ScrollController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _vehicleEntries = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredEntries =
      []; // For search results

  TextEditingController _searchController =
      TextEditingController(); // Controller for search bar
  String _searchQuery = ''; // Store search query
  Timer? _debounce; // Timer for debounce effect

  @override
  void initState() {
    super.initState();
    _getUserPhoneNumber();
    _fetchInitialVehicleData();
    _scrollController.addListener(_onScroll);

    // Listen to changes in the search field
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreData) {
      _fetchMoreVehicleData();
    }
  }

  // Debounce search to avoid rapid filtering on each keystroke
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _filterEntriesBySearchQuery();
      });
    });
  }

  // Filter vehicle entries based on the search query
  void _filterEntriesBySearchQuery() {
    if (_searchQuery.isEmpty) {
      _filteredEntries = _vehicleEntries;
    } else {
      _filteredEntries = _vehicleEntries.where((entry) {
        final vehicleNumber =
            (entry['vehicleNumber'] ?? '').toString().toLowerCase();
        return vehicleNumber.contains(_searchQuery);
      }).toList();
    }
  }

  // Fetch the current user's phone number
  void _getUserPhoneNumber() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userPhoneNumber = user.phoneNumber;
      });
      debugPrint("User Phone Number: $userPhoneNumber");
    } else {
      debugPrint("No user is currently logged in.");
    }
  }

  // Fetch initial vehicle data
  Future<void> _fetchInitialVehicleData() async {
    final querySnapshot = await _fetchVehicleData();
    setState(() {
      _vehicleEntries = querySnapshot.docs;
      _filteredEntries = _vehicleEntries; // Initially, display all entries
      if (querySnapshot.docs.length < _limit) {
        _hasMoreData =
            false; // No more data if the number of docs is less than the limit
      }
      _lastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    });
  }

  // Fetch more vehicle data when scrolled to bottom
  Future<void> _fetchMoreVehicleData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    final querySnapshot = await _fetchVehicleData();
    setState(() {
      _vehicleEntries.addAll(querySnapshot.docs);
      _filterEntriesBySearchQuery(); // Apply search filter after fetching more data
      _lastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      if (querySnapshot.docs.length < _limit) {
        _hasMoreData = false;
      }
      _isLoadingMore = false;
    });
  }

  // Fetch data from Firestore with pagination support
  Future<QuerySnapshot<Map<String, dynamic>>> _fetchVehicleData() async {
    final String phoneNumber = userPhoneNumber ?? '';
    final String year = DateTime.now().year.toString();
    final String month =
        DateTime.now().month.toString().replaceFirst(RegExp(r'^0'), '');

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('LoginUsers')
        .doc(phoneNumber)
        .collection('DueInDetails')
        .doc(year)
        .collection(month)
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    return query.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4.0,
        centerTitle: true,
        title: const Text(
          'Due IN Entry',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                          _onSearchChanged(''); // Clear search
                          FocusScope.of(context).unfocus();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach the scroll controller
              itemCount: _filteredEntries.length,
              itemBuilder: (context, index) {
                final doc = _filteredEntries[index];
                final vehicleNumber =
                    doc['vehicleNumber'] ?? 'No Vehicle Number';
                final selectedTime = doc['selectedTime'] ?? 'No Selected Time';
                final timestamp = (doc['timestamp'] as Timestamp).toDate();

                final formattedDate =
                    DateFormat('dd MMM yyyy').format(timestamp);
                final formattedTime = DateFormat('h:mm a').format(timestamp);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AfterScan(vehicleNumber: vehicleNumber),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Colors.yellow,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              vehicleNumber,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 10),
                            Text('Selected Time: $selectedTime',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 10),
                            Text('Date: $formattedDate',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 30),
                            const Icon(Icons.access_time,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Text('Time: $formattedTime',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoadingMore) // Show loading indicator when more data is being loaded
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 3)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the scroll controller when the widget is disposed
    _searchController.dispose(); // Dispose search controller
    _debounce?.cancel(); // Cancel the debounce timer
    super.dispose();
  }
}
