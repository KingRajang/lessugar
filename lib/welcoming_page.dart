import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_service.dart';
import 'dashboard.dart';
import 'survey.dart';
import 'styles.dart';



class WelcomingPage extends StatefulWidget {
  @override
  _WelcomingPageState createState() => _WelcomingPageState();
}

class _WelcomingPageState extends State<WelcomingPage> {
  bool _showSignIn = false;
  bool _showSignUp = false;
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  String _errorMessage = '';
  String _signUpErrorMessage = '';

  void _toggleSignIn() {
    setState(() {
      _showSignIn = !_showSignIn;
      _showSignUp = false;
    });
  }

  void _toggleSignUp() {
    setState(() {
      _showSignUp = !_showSignUp;
      _showSignIn = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_showSignIn || _showSignUp) {
      setState(() {
        _showSignIn = false;
        _showSignUp = false;
      });
      return false;
    }
    return true;
  }

  void _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }
    final user = await _authService.signInWithEmail(email, password);
    if (user != null) {
      setState(() {
        _errorMessage = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to sign in. Please check your credentials.';
      });
    }
  }

  void _handleGoogleSignIn() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      print('Google Sign-In failed');
    }
  }

  void _handleEmailSignUp() async {
    final email = _signUpEmailController.text.trim();
    final password = _signUpPasswordController.text.trim();
    final confirmPassword = _signUpConfirmPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _signUpErrorMessage = 'Please fill all fields';
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _signUpErrorMessage = 'Passwords do not match';
      });
      return;
    }
    final user = await _authService.signUpWithEmail(email, password);
    if (user != null) {
      setState(() {
        _signUpErrorMessage = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SurveyPage()), // Navigate to SurveyPage
      );
    } else {
      setState(() {
        _signUpErrorMessage = 'Failed to sign up. Please try again.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Container(
              color: coralColor,
              child: Center(
                child: Image.asset(
                  'assets/Welcoming Page.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: beigeColor, width: 2),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: _toggleSignIn,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        color: beigeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: beigeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: coralColor, width: 2),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: _toggleSignUp,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        color: coralColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: _showSignIn ? 0 : -MediaQuery.of(context).size.height * 0.75,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: coralColor),
                          onPressed: _toggleSignIn,
                        ),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: coralColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      onPressed: _handleEmailSignIn,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 20,
                          color: beigeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Or',
                      style: TextStyle(fontSize: 18, color: coralColor),
                    ),
                    SizedBox(height: 10),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/Google.svg',
                        width: 50,
                        height: 50,
                      ),
                      iconSize: 50,
                      onPressed: _handleGoogleSignIn,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _toggleSignUp,
                      child: Text(
                        'Don’t have an account? Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: coralColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: _showSignUp ? 0 : -MediaQuery.of(context).size.height * 0.75,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: coralColor),
                          onPressed: _toggleSignUp,
                        ),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: coralColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _signUpEmailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _signUpPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _signUpConfirmPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      onPressed: _handleEmailSignUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 20,
                          color: beigeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Or',
                      style: TextStyle(fontSize: 18, color: coralColor),
                    ),
                    SizedBox(height: 10),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/Google.svg',
                        width: 50,
                        height: 50,
                      ),
                      iconSize: 50,
                      onPressed: _handleGoogleSignIn,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _toggleSignIn,
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          color: coralColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_signUpErrorMessage.isNotEmpty)
                      Text(
                        _signUpErrorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
