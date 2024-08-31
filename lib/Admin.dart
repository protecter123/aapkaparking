import 'package:aapkaparking/Add%20pricing.dart';
import 'package:aapkaparking/Add%20vehicle.dart';
import 'package:aapkaparking/Adduser.dart';
import 'package:aapkaparking/Adduser2.dart';
import 'package:aapkaparking/Edit%20vehicle.dart';
import 'package:aapkaparking/colection.dart';
import 'package:aapkaparking/verify.dart';
import 'package:aapkaparking/viewUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
        preferredSize:
            const Size.fromHeight(100.0), // Increase the height of the AppBar
        child: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.yellow.shade700,
          leading: const SizedBox(), // Empty widget to keep title centered
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          title: Text(
            'Admin Dashboard',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 246, 235, 190),
                  Color.fromARGB(255, 248, 242, 130)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          childAspectRatio: 0.7, // Adjust to make the cards taller
          children: [
            _buildCard(
              'Add New User',
              'https://lottie.host/c5ea2a75-47eb-4000-805f-6c0708125ab7/rBQrP2Y1ea.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Adduser2()),
                );
              },
            ),
            _buildCard(
              'Add Vehicle',
              'https://lottie.host/142ea5df-9cc2-4a58-ad4d-ecc235a58c40/wrjztJKkxO.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddVehicle()),
                );
              },
            ),
            _buildCard(
              'Add Pricing',
              'https://lottie.host/98de12b2-ac8e-45c7-9097-8215c4ed6e8e/lOrOs3Tnye.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPrice()),
                );
              },
            ),
            _buildCard(
              'View Vehicles',
              'https://lottie.host/596b4cbe-85d9-4831-b674-7758a14c49c7/eInVdgYkqk.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditVehicle()),
                );
              },
            ),
            _buildCard(
              'Edit Users',
              'https://lottie.host/a03f56ad-8193-4fc2-bda6-59dda8bae766/rxGhb8W3Vw.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Viewuser()),
                );
              },
            ),
            _buildCard(
              'Collection',
              'https://lottie.host/8f2db930-c350-4c79-b123-fcb736cdf900/hcex28AduM.json',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Collection()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String animationUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 240, 227),
              Color.fromARGB(255, 251, 245, 236)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 32.481), // Adjust padding to fit the design
              child: Container(
                height: 140, // Adjust height as needed
                width: 140, // Adjust width as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                  color:
                      Colors.transparent, // Background color inside the circle
                ),
                child: ClipOval(
                  child: Lottie.network(animationUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            const Spacer(), // Pushes the title container to the bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.yellow.shade200, // Darker yellow color
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
