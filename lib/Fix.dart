import 'package:aapkaparking/fixrate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Fix extends StatefulWidget {
  final String keyboardtype;
  const Fix({super.key, required this.keyboardtype});

  @override
  State<Fix> createState() => _FixState();
}

class _FixState extends State<Fix> {
  final String userId = '+919999999999'; // Replace with your user ID
  final CollectionReference vehiclesCollection = FirebaseFirestore.instance
      .collection('AllUsers')
      .doc('+919999999999')
      .collection('Vehicles');

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'All Vehicles',
              textStyle: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 200),
            ),
          ],
          isRepeatingAnimation: true,
          repeatForever: true,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: vehiclesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.yellow,
            ));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vehicle images found.'));
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var imageUrl = doc['vehicleImage'];
              var vehicleName = capitalize(doc['vehicleName'] ?? 'Unknown');

              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Fixirate(
                            imgUrl: imageUrl,
                            keyboardtype: widget.keyboardtype),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 10.0,
                    color:
                        const Color.fromARGB(255, 248, 246, 225), // 3D effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 134, // Reduce height for a better layout
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              // Asset Image as Placeholder
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/animations/placeholder.png', // Replace with your asset image path
                                  fit: BoxFit.cover,
                                  height: 134, // Same height as the container
                                  width: double
                                      .infinity, // Fill the container's width
                                ),
                              ),
                              // CachedNetworkImage with Loader
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  height: 134, // Same height as the container
                                  width: double
                                      .infinity, // Fill the container's width
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    color: Colors
                                        .transparent, // Transparent background over asset image
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.yellow),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            vehicleName,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
