import 'package:aapkaparking/verify.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  int _current = 0;
  final CarouselController _carouselController = CarouselController();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  final List<String> lottieUrls = [
    'assets/animations/slide3.json',
    'assets/animations/slide2.json',
    'assets/animations/slide1.json',
  ];

  final List<String> textList = [
    "Welcome to the best parking app!",
    "Find and book parking spots easily.",
    "Enjoy a hassle-free parking experience.",
  ];

  bool _isLoading = true;
  final List<Widget> _lottieWidgets = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _colorAnimation = ColorTween(
      begin: Color(0xFFFFD700),
      end: Color(0xFFFFE082), // Different shades of yellow
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    _preloadLottieAnimations();
  }

  Future<void> _preloadLottieAnimations() async {
    for (var url in lottieUrls) {
      _lottieWidgets.add(Lottie.asset(url));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateToNextPage() {
    if (_current == _lottieWidgets.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Verify()),
      );
    } else {
      _carouselController.nextPage();
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9C4), // Light yellow color
        elevation: 0,
        title:  Text(
          'Aapka parking',
          style:GoogleFonts.sourceCodePro(fontSize:26,color:  Colors.black,fontWeight: FontWeight.bold)
          
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _colorAnimation.value ?? Color(0xFFFFD700),
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : CarouselSlider(
                      items: _lottieWidgets,
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        viewportFraction: 1.0,
                        height: double.infinity,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textList[_current],
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[800],
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: lottieUrls.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? Color(0xFFFFD700) // Yellow color
                          : Color(0xFFFFD700).withOpacity(0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: ElevatedButton(
              onPressed: _animateToNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700), // Yellow color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 5.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
