import 'package:aapkaparking/Add%20pricing.dart';
import 'package:aapkaparking/Add%20vehicle.dart';
import 'package:aapkaparking/AddAdmin.dart';
import 'package:aapkaparking/Adduser2.dart';
import 'package:aapkaparking/Edit%20vehicle.dart';
import 'package:aapkaparking/colection.dart';
import 'package:aapkaparking/verify.dart';
import 'package:aapkaparking/viewUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  double _totalAmount = 0.0;
  @override
  void initState() {
    super.initState();
    _fetchTotalAmount();
    _loadCachedData();
  }

  String? imageUrl;
  String? parkingName;
  String? duemoney;
  String? fixmoney;
  String? passmoney;
  Future<void> _fetchTotalAmount() async {
    try {
      // Getting the current user's phone number from Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user is currently signed in.');
        return;
      }

      String currentUserPhone = currentUser.phoneNumber ?? '';
      if (currentUserPhone.isEmpty) {
        print('Current user phone number is not available.');
        return;
      }

      // Getting today's date in yyyy-MM-dd format
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Firestore path to the user's collection
      CollectionReference usersRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhone)
          .collection('Users');

      double total = 0.0;

      // Get all documents in the 'Users' collection
      QuerySnapshot usersSnapshot = await usersRef.get();

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        // Check if the MoneyCollection sub-collection exists
        CollectionReference moneyCollectionRef =
            usersRef.doc(userDoc.id).collection('MoneyCollection');

        DocumentSnapshot snapshot =
            await moneyCollectionRef.doc(todayDate).get();

        if (snapshot.exists) {
          // Retrieve the data from the document
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          // Check for individual fields and add them to the total if they exist
          if (data.containsKey('dueMoney')) {
            duemoney = data['dueMoney'].toString();
            int? dueMoney = int.tryParse(data['dueMoney'].toString());
            if (dueMoney != null) {
              total += dueMoney.toDouble();
            }
          }

          if (data.containsKey('fixMoney')) {
            fixmoney = data['fixMoney'].toString();
            int? fixMoney = int.tryParse(data['fixMoney'].toString());
            if (fixMoney != null) {
              total += fixMoney.toDouble();
            }
          }

          if (data.containsKey('passMoney')) {
            passmoney = data['passMoney'].toString();
            int? passMoney = int.tryParse(data['passMoney'].toString());
            if (passMoney != null) {
              total += passMoney.toDouble();
            }
          }
        }
      }

      setState(() {
        _totalAmount = total; // Update the state with the total amount
      });
    } catch (e) {
      print('Error fetching total amount: $e');
    }
  }

  void _logout() {
    _showLogoutDialog();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 247, 235, 217),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Log out?" heading at the top
                Text(
                  'Log out?',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 40, 40, 40),
                  ),
                ),
                const SizedBox(height: 10),
                // Logout confirmation text
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 40, 40, 40),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Yes Button
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Verify()),
                        ); // Navigate to the Verify screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor:
                            Colors.transparent, // Transparent background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Color.fromARGB(255, 40, 40, 40),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // No Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 124, 244, 109),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
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

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(5), // Rounded corners for the dialog
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content to the left
                  children: [
                    // "Exit app" heading
                    const Text(
                      'Exit app',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Confirmation message
                    const Text(
                      'Do you want to exit the app?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    // Row with "Yes" and "No" buttons
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align buttons to the right
                      children: [
                        // "Yes" button with transparent background (only text)
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Close dialog and exit app
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // "No" button with green background
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Close dialog, stay in app
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 124, 244,
                                109), // Green background for "No"
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  void showTodayCollectionDialog(BuildContext context, String? fixmoney,
      String? duemoney, String? passmoney) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10), // Rectangular shape with rounded edges
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Text for Today's Detailed Revenue
                const Text(
                  'Today\'s Detailed Revenue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Row containing the three small containers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // FIX Container
                    GestureDetector(
                      onTap: () {
                        print('FIX tapped');
                      },
                      child: Container(
                        width: 80, // Fixed width
                        height: 80, // Fixed height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('FIX',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(fixmoney ?? '0',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // DUE Container
                    GestureDetector(
                      onTap: () {
                        print('DUE tapped');
                      },
                      child: Container(
                        width: 80, // Fixed width
                        height: 80, // Fixed height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('DUE',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(duemoney ?? '0',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                   const SizedBox(
                      width: 10,
                    ),
                    // PASS Container
                    GestureDetector(
                      onTap: () {
                        print('PASS tapped');
                      },
                      child: Container(
                        width: 80, // Fixed width
                        height: 80, // Fixed height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('PASS',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(passmoney ?? '0',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Close Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Black background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchAndSaveParkingDetails() async {
    // Get the current authenticated user's phone number
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserPhoneNumber =
          user.phoneNumber ?? ""; // Get phone number from Firebase Auth

      // Firestore document reference for the current user
      final docRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentUserPhoneNumber);

      // Fetch parking details from Firestore
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        // Extract 'ParkingName' and 'ParkingLogo' fields
        String parkingName = snapshot['ParkingName'];
        String parkingLogo = snapshot['ParkingLogo'];

        // Save the fetched data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('cachedParkingName', parkingName);
        await prefs.setString('cachedParkingLogo', parkingLogo);
      } else {
        print('Document does not exist');
      }
    } else {
      print('No user is signed in');
    }
  }

  Future<String?> getCachedImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cachedParkingLogo');
  }

  Future<String?> getCachedParkingName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cachedParkingName');
  }

  Future<void> _loadCachedData() async {
    String? cachedUrl = await getCachedImageUrl();
    String? cachedName = await getCachedParkingName();
    setState(() {
      imageUrl = cachedUrl;
      parkingName = cachedName;
    });

    // If image URL or name is not cached, fetch from Firebase
    if (cachedUrl == null || cachedName == null) {
      await fetchAndSaveParkingDetails();
      _loadCachedData(); // Reload cached data after fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context); // Show exit dialog on back press
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 223, 221, 221),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            shadowColor: const Color.fromARGB(255, 190, 190, 190),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(00),
                bottomRight: Radius.circular(00),
              ),
            ),
            elevation: 1,
            //leading: const SizedBox(), // Empty widget to keep title centered
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                color: Colors.green,
              ),
            ],
            title: Text(
              'Admin Dashboard',
              style: GoogleFonts.ubuntu(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu), // Drawer icon
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
        ),
        drawer: Drawer(
          width: 250,
          surfaceTintColor: const Color.fromARGB(255, 236, 219, 178),
          shadowColor: Colors.orangeAccent, // Subtle shadow for 3D effect
          elevation: 45,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Custom DrawerHeader with parking logo and name
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient:const LinearGradient(
                    colors: [
                      const Color.fromARGB(
                          255, 103, 99, 99), // Darker grey for depth
                      const Color.fromARGB(
                          255, 233, 205, 162), // Orange gradient transition
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(imageUrl!),
                        backgroundColor:
                            Colors.grey.shade300, // Border around the image
                      )
                    else
                      const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    if (parkingName != null)
                      Text(
                        parkingName!,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 255, 255, 255), // Orange for text contrast
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily:
                              'GoogleFontName', // Replace with the Google Font you want
                        ),
                      )
                    else
                      const Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.green),
                title: const Text('Add Admin details'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddAdmin(imgUrl: imageUrl, Name: parkingName),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 500,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container for the image
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.grey, // Grey filter for the logo
                        BlendMode.srcATop, // Blend mode
                      ),
                      child: Image.asset(
                        'assets/aapka logo.webp', // Image asset path
                        width: 15,
                        height: 15,
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Space between the logo and text
                    const Text(
                      'Aapka Parking \u00A9',
                      style: TextStyle(
                        color: Color.fromARGB(255, 158, 158, 158), // Text color
                        fontSize: 15, // Font size
                        fontWeight: FontWeight.bold, // Bold text
                      ),
                    ),
                  ],
                ),
              )
              // Add more ListTiles as needed
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showTodayCollectionDialog(
                      context, fixmoney, duemoney, passmoney);
                },
                child: Container(
                  height: 150,
                  width: double.infinity, // Ensures it takes the full width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.yellow[50], // Light yellow background color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage(
                          'assets/animations/Adminback.jpg'), // Background image asset
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Revenue',
                            style: GoogleFonts.libreBaskerville(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 2, 2,
                                  2), // Adjust color based on background
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Prevents overflow
                          ),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(
                                'assets/animations/Rupee-Sign-Money-PNG.png'), // Circle avatar with image
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 25), // Pushes content to the bottom
                      Container(
                        width:
                            double.infinity, // Ensures it takes the full width
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(140, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹ ${_totalAmount.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 28, // Larger font size for emphasis
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 8, 8,
                                      8), // Colorful text for total amount
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month, // Colorful icon
                                    color: Color.fromARGB(255, 7, 7, 7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd-MMM').format(DateTime
                                        .now()), // Formats the date as dd-MMM
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 1, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.black, // Color of the divider
                thickness: 1,
                indent: 0,
                endIndent: 0, // Thickness of the divider
                height: 1, // Space above and below the divider
              ),

              const SizedBox(
                height: 10,
              ), // Add spacing between the container and grid
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 1, // Adjust to make the cards taller
                    children: [
                      _buildCard(
                          title: 'Add User',
                          imagePath: 'assets/animations/wp2722623.png',
                          animationUrl:
                              'https://lottie.host/c5ea2a75-47eb-4000-805f-6c0708125ab7/rBQrP2Y1ea.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Adduser2()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 254, 171, 167)),
                      _buildCard(
                          title: 'Add Vehicle',
                          imagePath: 'assets/animations/OIP (3).jpeg',
                          animationUrl:
                              'https://lottie.host/142ea5df-9cc2-4a58-ad4d-ecc235a58c40/wrjztJKkxO.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddVehicle()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 251, 241, 153)),
                      _buildCard(
                          title: 'Add Pricing',
                          imagePath: 'assets/animations/1353554.webp',
                          animationUrl:
                              'https://lottie.host/98de12b2-ac8e-45c7-9097-8215c4ed6e8e/lOrOs3Tnye.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddPrice()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 151, 253, 156)),
                      _buildCard(
                          title: 'View Vehicles',
                          imagePath:
                              'assets/animations/pngtree-best-silk-wallpaper-any-one-can-loved-it-image_590012.jpg',
                          animationUrl:
                              'https://lottie.host/c024d909-3db9-4bc2-8aff-b3b4be0c6c5c/iUF7xCnkzl.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditVehicle()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 144, 205, 255)),
                      _buildCard(
                          title: 'Edit Users',
                          imagePath: 'assets/animations/R.jpeg',
                          animationUrl:
                              'https://lottie.host/a03f56ad-8193-4fc2-bda6-59dda8bae766/rxGhb8W3Vw.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Viewuser()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 168, 141, 249)),
                      _buildCard(
                          title: 'Collection',
                          imagePath: 'assets/animations/wp2722623.png',
                          animationUrl:
                              'https://lottie.host/464e74ce-b867-41f5-8035-7904f651eb79/unGc97LCpv.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Collection()),
                            );
                          },
                          backgroundColor: Color.fromARGB(255, 253, 178, 132)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String animationUrl,
    required VoidCallback onTap,
    required Color backgroundColor,
    required String imagePath, // Image path argument
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor, // Custom background color
          image: DecorationImage(
            image: AssetImage(imagePath), // Set image as background
            fit: BoxFit.cover, // Ensure the image covers the entire container
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(4, 4), // Position of the shadow
              blurRadius: 10, // Blur effect
              spreadRadius: 1, // How much the shadow spreads
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: Offset(-4, -4), // Light effect for 3D look
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 43,
              child: Container(
                height: 90, // Smaller size for the animation
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color.fromARGB(0, 0, 0, 0), width: 1),
                  color: Colors.transparent,
                ),
                child: ClipOval(
                  child: Lottie.network(animationUrl,
                      fit: BoxFit.cover, repeat: false),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit
                          .scaleDown, // Ensures the text scales down if needed
                      child: Container(
                        width: 140,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(140, 255, 255, 255),
                            borderRadius: BorderRadius.all(Radius.circular(7))),
                        child: Center(
                          child: Text(
                            title,
                            style: GoogleFonts.lexend(
                              // Cute Google Font
                              fontSize: 18, // Fixed font size
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
