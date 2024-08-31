import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final TextEditingController vehicleNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  // void _pickImage(ImageSource source) async {
  //   final pickedFile = await _picker.pickImage(source: source);
  //   if (pickedFile != null) {
  //     final compressedImage = await _compressImage(File(pickedFile.path));
  //     setState(() {
  //       _image = XFile(compressedImage.path);
  //     });
  //   }
  // }

  Future<XFile> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, path.basename(file.path));

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );
    return compressedImage!;
  }

  void _getImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    if (pickedFile != null) {
                      _image = File(pickedFile.path);
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    if (pickedFile != null) {
                      _image = File(pickedFile.path);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveVehicleDetails() async {
    if (_image == null || vehicleNameController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required details')),
      );
      return;
    }

    try {
      // Get the current user's phone number or unique ID
      final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

      if (phoneNumber.isEmpty) {
        // Handle case where phoneNumber is null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Check if the vehicle name already exists
      final firestoreRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(phoneNumber)
          .collection('Vehicles');

      final querySnapshot = await firestoreRef
          .where('vehicleName', isEqualTo: vehicleNameController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show SnackBar if vehicle already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle already added')),
        );
        return;
      }

      // Upload the image to Firebase Storage
      final fileName = path.basename(_image!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicles/$phoneNumber/$fileName');
      final uploadTask = await storageRef.putFile(File(_image!.path));

      // Get the download URL of the uploaded image
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save the vehicle details in Firestore
      await firestoreRef.doc().set({
        'vehicleName': vehicleNameController.text.trim(),
        'vehicleImage': downloadUrl,
      });

      // Show success dialog with Lottie animation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                    'assets/animations/Add vehicle.json'), // Replace with your Lottie file URL
                const SizedBox(height: 20),
                const Text(
                  'Vehicle added successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicle details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 180),
                painter: InvertedTrianglePainter(),
              ),
              Positioned(
                top: 50, // Positioning the back icon
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.black),
                ),
              ),
              Positioned(
                top: 100,
                left: 140,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.yellow.shade700,
                      child: GestureDetector(
                        onTap: () {
                          _getImage;
                        },
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton(
                        onPressed: _getImage,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.yellow.shade700,
                          padding: EdgeInsets.all(8), // Button color
                        ),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 190,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Lottie.network(
                          'https://lottie.host/8b8345db-830e-4916-ac30-ba1a117bb50e/vL4ghnwtfM.json',
                          fit: BoxFit.contain,
                          height: 300,
                          width: 300),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70.0, top: 20),
                      child: Container(
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.zero,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Add Vehicle',
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              TextField(
                                controller: vehicleNameController,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.yellow),
                                  ),
                                  hintText: 'Enter vehicle name',
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 19),
                                  prefixIcon: const Icon(Icons.directions_car,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveVehicleDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Vehicle Details',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvertedTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
