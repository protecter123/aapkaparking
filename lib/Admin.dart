import 'package:aapkaparking/Add%20pricing.dart';
import 'package:aapkaparking/Add%20vehicle.dart';
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
  }


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
      CollectionReference moneyCollectionRef = usersRef
          .doc(userDoc.id)
          .collection('MoneyCollection');

      DocumentSnapshot snapshot = await moneyCollectionRef.doc(todayDate).get();

      if (snapshot.exists) {
        // Sum up all integer values in the document
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        data.forEach((key, value) {
          int? intValue = int.tryParse(value.toString());
          if (intValue != null) {
            total += intValue.toDouble();
          }
        });
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Log out the user from Firebase Authentication
                        await FirebaseAuth.instance.signOut();

                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Verify()),
                        ); // Navigate to the Verify screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 250, 1, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 31, 249, 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.black, fontSize: 18),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          elevation: 10,
          leading: const SizedBox(), // Empty widget to keep title centered
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          title: Text(
            'Admin Dashboard',
            style: GoogleFonts.baskervville(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.yellow[50], // Light yellow background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // Changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      'Today\'s Collection',
                      style: GoogleFonts.pangolin(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevents overflow
                    ),
                  ),
                  SizedBox(height: 30),
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit
                            .scaleDown, // Ensures the text scales down if needed
                        child: Text(
                          '₹ ${_totalAmount.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign:
                              TextAlign.right, // Aligns text to the right
                          overflow: TextOverflow.ellipsis, // Prevents overflow
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 50), // Add spacing between the container and grid
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 30.0,
                  childAspectRatio: 1.1, // Adjust to make the cards taller
                  children: [
                    _buildCard(
                        title: 'Add New User',
                        animationUrl:
                            'https://lottie.host/c5ea2a75-47eb-4000-805f-6c0708125ab7/rBQrP2Y1ea.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Adduser2()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 253, 218, 216)),
                    _buildCard(
                        title: 'Add Vehicle',
                        animationUrl:
                            'https://lottie.host/142ea5df-9cc2-4a58-ad4d-ecc235a58c40/wrjztJKkxO.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddVehicle()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 249, 245, 207)),
                    _buildCard(
                        title: 'Add Pricing',
                        animationUrl:
                            'https://lottie.host/98de12b2-ac8e-45c7-9097-8215c4ed6e8e/lOrOs3Tnye.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPrice()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 181, 246, 184)),
                    _buildCard(
                        title: 'View Vehicles',
                        animationUrl:
                            'https://lottie.host/596b4cbe-85d9-4831-b674-7758a14c49c7/eInVdgYkqk.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditVehicle()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 199, 228, 252)),
                    _buildCard(
                        title: 'Edit Users',
                        animationUrl:
                            'https://lottie.host/a03f56ad-8193-4fc2-bda6-59dda8bae766/rxGhb8W3Vw.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Viewuser()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 217, 206, 251)),
                    _buildCard(
                        title: 'Collection',
                        animationUrl:
                            'https://lottie.host/8f2db930-c350-4c79-b123-fcb736cdf900/hcex28AduM.json',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Collection()),
                          );
                        },
                        backgroundColor: Color.fromARGB(255, 255, 230, 215)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String animationUrl,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: backgroundColor, // Custom background color
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
              left: 20,
              child: Container(
                height: 76, // Smaller size for the animation
                width: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color.fromARGB(0, 0, 0, 0), width: 1),
                  color: Colors.transparent,
                ),
                child: ClipOval(
                  child: Lottie.network(animationUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 21,
              right: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FittedBox(
                      alignment: Alignment.bottomLeft,
                      fit: BoxFit
                          .scaleDown, // Ensures the text scales down if needed
                      child: Text(
                        title,
                        style: GoogleFonts.pangolin(
                          // Cute Google Font
                          fontSize: 18, // Fixed font size
                          fontWeight: FontWeight.normal,
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
