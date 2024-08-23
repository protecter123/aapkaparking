import 'package:aapkaparking/otpscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';


class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 90,
      color: Colors.yellow.shade700,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 249, 251, 187),
          backgroundColor: Color.fromARGB(255, 0, 4, 57),
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  VerifyState createState() => VerifyState();
}

class VerifyState extends State<Verify> {
  TextEditingController phonecontroller = TextEditingController();
  bool _isValid = true;
  String countryCode = "+91";
  bool _isloading = false;
  bool _iscompleted = false;
  bool _buttonenable = false;
  bool clear = false;

  void generateOTP() async {
    setState(() {
      _isloading = true;
    });

    final phoneNumber = '$countryCode${phonecontroller.text}';
    print('Attempting to verify phone number: $phoneNumber');

    try {
      // Check if the phone number is already in the 'users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('loginUsers')
          .doc(phoneNumber)
          
          .get();
      final userDoc2 = await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(phoneNumber)
          .get();

      if (userDoc.exists || userDoc2.exists) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            // Auto-retrieval of OTP completed (instant verification).
            print('Auto verification completed with credential: $credential');
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _isloading = false;
            });
            print('Verification failed: ${e.message}');
            // Display error message to the user or handle it accordingly
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isloading = false;
            });
            print(
                'Code sent to $phoneNumber with verificationId: $verificationId');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  verificationId: verificationId,
                  phonecontroller: phonecontroller,
                  generateOTP: generateOTP,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('Auto retrieval timeout for verificationId: $verificationId');
          },
          timeout: const Duration(seconds: 60),
        );
      } else {
        setState(() {
          _isloading = false;
        });
        // Show custom bottom sheet
        print('Showing BottomSheet for invalid phone number');
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration:const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child:const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 30),
                SizedBox(height: 8),
                Text(
                  'Admin doesn\'t allow this number',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      print('Error occurred: $e');
      // Handle error (e.g., show a bottom sheet with the error message)
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const  Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(height: 8),
              Text(
                'Error occurred: $e',
                style:const TextStyle(color: Colors.black, fontSize: 16),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Scaffold (
        backgroundColor: Color.fromARGB(255, 247, 249, 229),
        appBar: AnimatedAppBar(title: 'Sign In'),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: SizedBox(
                    height: 400,
                    width: 400,
                    child: Container(
                      child: Lottie.asset(
                        'assets/animations/verify.json',
                        fit: BoxFit.contain,
                      ),
                    )),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //ImageSlider(),
                    SizedBox(
                      height: 90,
                    ),
                    Container(height: 330, child: Text("")),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 340,
                      height: 50,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                            ),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _iscompleted
                                        ? Color.fromARGB(255, 206, 181, 136)
                                        : _isValid
                                            ? Color.fromARGB(255, 108, 95, 42)
                                            : Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: _iscompleted
                                      ? LinearGradient(
                                          colors: [
                                            Colors.yellow.shade100,
                                            Colors.yellow.shade300,
                                            Colors.yellow.shade400,
                                            Colors.yellow.shade600,
                                            Color.fromARGB(255, 241, 245, 23),
                                            Color.fromARGB(255, 254, 254, 1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 16),
                                  child: TextField(
                                    controller: phonecontroller,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 20),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      hintText: 'Enter mobile number',
                                      hintStyle: TextStyle(color: Colors.brown,fontSize: 20),
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          '$countryCode |',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color.fromARGB(255, 9, 9, 9),
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                              minWidth: 0, minHeight: 0),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _isValid =
                                            value.startsWith(RegExp('[6-9]'));
                                        if (value.length == 10) {
                                          _iscompleted = true;
                                          _buttonenable = true;
                                        }
                                        if (value.isNotEmpty) {
                                          clear = true;
                                        }
                                        if (value.isEmpty) {
                                          _isValid = true;
                                          _iscompleted = false;
                                          _isloading = false;
                                          clear = false;
                                        }
                                        if (value.length < 10) {
                                          _buttonenable = false;
                                          _iscompleted = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 307.0, top: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  phonecontroller.clear();
                                  clear = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0),
                                child: CircleAvatar(
                                  backgroundColor: clear
                                      ? !_isValid
                                          ? const Color.fromARGB(
                                              255, 248, 120, 133)
                                          : _iscompleted
                                              ? const Color.fromARGB(
                                                  255, 144, 249, 172)
                                              : const Color.fromARGB(
                                                  255, 69, 69, 69)
                                      : Colors.transparent,
                                  radius: 15,
                                  child: Icon(
                                    _iscompleted ? Icons.check : Icons.clear,
                                    color: clear
                                        ? !_isValid
                                            ? const Color.fromARGB(
                                                255, 250, 20, 4)
                                            : _iscompleted
                                                ? Color.fromARGB(255, 27, 130, 1)
                                                : Color.fromARGB(
                                                    255, 207, 206, 206)
                                        : const Color.fromARGB(0, 255, 193, 7),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 70.0),
                      child: Text(
                        !_isValid ? "Start the number between 6-9" : "",
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Stack(children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: _buttonenable ? generateOTP : null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                _buttonenable
                                    ? Colors.yellow.shade700
                                    : Colors.grey.shade400,
                              ),
                              fixedSize:
                                  WidgetStateProperty.all<Size>(Size(340, 47)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_isloading)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Loader(),
                            ),
                          ),
                      ]),
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

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  AnimatedAppBar({required this.title, Key? key}) : super(key: key);

  @override
  _AnimatedAppBarState createState() => _AnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AnimatedAppBarState extends State<AnimatedAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  late Animation<Color?> _colorAnimation3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
     const SystemUiOverlayStyle(
        statusBarColor:
            Color.fromARGB(243, 0, 0, 0), // Make the status bar transparent
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for light backgrounds
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: const Color.fromARGB(255, 254, 232, 37),
      end: Color.fromARGB(255, 138, 134, 16),
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: const Color.fromARGB(255, 153, 138, 2),
      end: Colors.yellow.shade500,
    ).animate(_controller);

    _colorAnimation3 = ColorTween(
      begin: Color.fromARGB(255, 247, 247, 104),
      end: Colors.yellowAccent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value:const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Dark icons
          statusBarBrightness: Brightness.light, // For iOS
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation1.value!,
                      _colorAnimation2.value!,
                      _colorAnimation3.value!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 4, 4, 4),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            );
          },
        ));
  }
}

class AnimatedImage extends StatefulWidget {
  final String imageUrl;

  const AnimatedImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _AnimatedImageState createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true); // Reverse animation for continuous loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 800,
            ),
          ),
        );
      },
    );
  }
}
