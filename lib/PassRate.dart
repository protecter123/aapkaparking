import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'reciept.dart';

class Passrate extends StatefulWidget {
  final String imgUrl;
  final String keyboardtype;

  const Passrate({super.key, required this.imgUrl, required this.keyboardtype});

  @override
  _PassrateState createState() => _PassrateState();
}

class _PassrateState extends State<Passrate> {
  int? _selectedContainerIndex;
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? pricingData;

  Future<void> fetchPricingDetails() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('AllUsers')
        .doc('+919999999999')
        .collection('Vehicles')
        .where('vehicleImage', isEqualTo: widget.imgUrl)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        pricingData = snapshot.docs.first.data();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPricingDetails();
  }

  void _generateReceipt() {
    if (_selectedContainerIndex != null &&
        _controller.text.isNotEmpty &&
        pricingData != null) {
      var selectedRate = _selectedContainerIndex == 0
          ? '1 Month Pass'
          : _selectedContainerIndex == 1
              ? '2 Month Pass'
              : '3 Month Pass';

      var price = _selectedContainerIndex == 0
          ? pricingData!['PassPrice']
          : _selectedContainerIndex == 1
              ? (int.tryParse(pricingData!['PassPrice'])! * 2).toString()
              : (int.tryParse(pricingData!['PassPrice'])! * 3).toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Receipt(
            vehicleNumber: _controller.text,
            rateType: selectedRate,
            price: price,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Parking Rates',
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
      ),
      body: pricingData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildPricingContainer(
                            context,
                            '1 Month Pass',
                            pricingData!['PassPrice'],
                            0,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '2 Month Pass',
                            (int.tryParse(pricingData!['PassPrice'])! * 2)
                                .toString(),
                            1,
                          ),
                          const SizedBox(height: 16),
                          _buildPricingContainer(
                            context,
                            '3 Month Pass',
                            (int.tryParse(pricingData!['PassPrice'])! * 3)
                                .toString(),
                            2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width -
                          48, // Decreases the width by 10 pixels
                      child: TextField(
                        controller: _controller,
                        keyboardType: widget.keyboardtype == 'numeric'
                            ? TextInputType.number
                            : TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Add vehicle number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 231, 242, 136),
                              Color.fromARGB(255, 77, 50, 80)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width -
                          48,
                          height: 70,
                          alignment: Alignment.center,
                          child: Text(
                            'Generate Receipt',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPricingContainer(
      BuildContext context, String timing, String? price, int index) {
    bool isSelected = _selectedContainerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContainerIndex = index;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/clock.json',
                        height: 23, width: 23),
                    const SizedBox(width: 4),
                    Text(timing),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 50),
              child: Text(
                '₹ ${price ?? 0}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Lottie.asset('assets/animations/line.json', repeat: false),
            ),
          ],
        ),
      ),
    );
  }
}
