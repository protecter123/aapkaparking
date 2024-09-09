import 'dart:async';
import 'package:aapkaparking/Admin.dart';
import 'package:aapkaparking/users.dart';
import 'package:aapkaparking/verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 0),
            Color.fromARGB(255, 255, 255, 0),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 249, 224, 168),
          backgroundColor: Colors.black,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final TextEditingController phonecontroller;
  final Function generateOTP;

  const OtpScreen(
      {Key? key,
      required this.verificationId,
      required this.phonecontroller,
      required this.generateOTP})
      : super(key: key);

  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  bool _showResendButton = false;
  Timer? _timer;
  int _secondsRemaining = 60;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();
  bool _isloading = false;
  bool buttonenable = false;
  bool clearenable = false;

  late AnimationController _bgAnimationController;
  late Animation<Alignment> _bgAnimation;

  @override
  void initState() {
    super.initState();
    startTimer();
    SystemChrome.setSystemUIOverlayStyle(
     const SystemUiOverlayStyle(
        statusBarColor:
            Color.fromARGB(243, 0, 0, 0), // Make the status bar transparent
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for light backgrounds
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    _bgAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _bgAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _bgAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _showResendButton = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    String otp = _otpController.text.trim();
    setState(() {
      _isloading = true;
    });

    if (otp.length == 6) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );

        await _auth.signInWithCredential(credential);

        String phoneNumber = '+91${widget.phonecontroller.text.trim()}';

        try {
          // Check in the Admin collection
          CollectionReference admins =
              FirebaseFirestore.instance.collection('AllUsers');
          DocumentSnapshot adminDoc = await admins.doc(phoneNumber).get();

          // Check in the Users collection
          CollectionReference users =
              FirebaseFirestore.instance.collection('LoginUsers');
          DocumentSnapshot userDoc = await users.doc(phoneNumber).get();

          setState(() {
            _isloading = false;
          });

          if (adminDoc.exists) {
            bool isRegistered = adminDoc.get('isdeleted') ?? false;
            if (isRegistered) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdminPage()), // Replace with your AdminPage
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            }
          } else if (userDoc.exists) {
            bool isRegistered = userDoc.get('isdeleted') ?? false;
            if (isRegistered) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const UserDash()), // Replace with your BottomScreen
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserDash()),
              );
            }
          } else {
            
          }
        } catch (e) {
          print('Error checking phone number: $e');
        }
      } catch (e) {
        setState(() {
          _isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong OTP, please try again.')),
        );
      }
    } else {
      setState(() {
        _isloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP.')),
      );
    }
  }

  void _resendOTP() {
    setState(() {
      _showResendButton = false;
      _secondsRemaining = 60;
    });
    startTimer();
    widget.generateOTP();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value:const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Dark icons
          statusBarBrightness: Brightness.light, // For iOS
        ),
        child: Scaffold(
          backgroundColor: Colors.blue,
          body: AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return SingleChildScrollView(
                child: Container(
                  height: 900,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: _bgAnimation.value,
                      end: Alignment.centerRight,
                      colors:const [
                         Color.fromARGB(255, 246, 240, 187),
                         Color.fromARGB(255, 252, 250, 226),
                        Color.fromARGB(255, 249, 249, 239),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 350, top: 60),
                            child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                color: Color.fromARGB(255, 7, 7, 7),
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Verify(),
                                    ),
                                  );
                                }),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 20),
                            child: Container(
                              width: 330,
                              height: 270,
                              color: const Color.fromARGB(0, 255, 172, 64),
                              child: Lottie.asset('assets/animations/otp.json'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 0, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Pinput(
                                    length: 6,
                                    controller: _otpController,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.length == 6) {
                                          buttonenable = true;
                                        } else {
                                          buttonenable = false;
                                        }
                                        clearenable = value.isNotEmpty;
                                      });
                                    },
                                    defaultPinTheme: PinTheme(
                                      width: 40,
                                      height: 55,
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors
                                            .black, // Using black text for high contrast
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 246, 246,
                                                167), // Very light gray
                                            Color(0xFFFDFEFE), // Almost white
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors
                                              .orange, // Blue border for better contrast
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:const Color.fromARGB(
                                                    255, 126, 129, 116)
                                                .withOpacity(0.5),
                                            blurRadius: 10,
                                            offset: const Offset(2,
                                                4), // Shadow offset for depth
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: IconButton(
                                    onPressed: () {
                                      _otpController.text = '';
                                    },
                                    icon: Icon(
                                      buttonenable ? Icons.check : Icons.clear,
                                      color: clearenable
                                          ? const Color.fromARGB(255, 157, 255, 0)
                                          : Colors.transparent,
                                      size: 25,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        const  SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Resend OTP in $_secondsRemaining seconds',
                                  style: TextStyle(
                                    fontSize:
                                        // ignore: deprecated_member_use
                                        MediaQuery.of(context).textScaleFactor *
                                            11, // Responsive font size
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02), // Responsive spacing
                                if (_showResendButton)
                                  TextButton(
                                    onPressed: _resendOTP,
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color:const Color.fromARGB(255, 255, 70, 64),
                                        fontSize: MediaQuery.of(context)
                                                // ignore: deprecated_member_use
                                                .textScaleFactor *
                                            9, // Responsive font size
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                         const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: buttonenable ? _verifyOTP : null,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      buttonenable
                                          ? Color.fromARGB(255, 255, 255, 0)
                                          : Colors.grey,
                                    ),
                                    fixedSize: WidgetStateProperty.all<Size>(
                                      const  Size(270, 55)),
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .zero, // Set to 0 for a rectangle
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (_isloading)
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 50.0, top: 5),
                                    child: Loader(),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Verify(),
                                ),
                              );
                            },
                            child: const Text(
                              'Change Number',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}


