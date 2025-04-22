import 'package:final_project/WelcomeScreen.dart';
import 'package:final_project/login/register.dart';
import 'package:final_project/withoutlogin/wel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _email = '';
  String _password = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        User? user = userCredential.user;
        if (user != null) {
          // Fetch user details
          UserDetail userDetail = await _fetchUserDetails(user);

          // Navigate to WelcomeScreen with user details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(userDetail),
            ),
          );
        }
      } on FirebaseAuthException {
        // Handle login errors (e.g., invalid email or password)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log in..'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<UserDetail> _fetchUserDetails(User user) async {
    // You can fetch user details from Firebase or any other source
    // For now, let's assume we only have the user's email
    return UserDetail(displayName: user.displayName, email: user.email);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 198, 30, 30),
    ));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("image/nattu-adnan-Ai2TRdvI6gM-unsplash.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 60),
                  Image.asset(
                    "image/download__1_-removebg-preview (1).png",
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email),
                                  labelText: 'Email',
                                  border: InputBorder.none,
                                ),
                                onSaved: (value) => _email = value!,
                                validator: (value) =>
                                    value!.isEmpty || !value.contains('@')
                                        ? 'Please enter a valid email'
                                        : null,
                              ),
                              Divider(),
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  labelText: 'Password',
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                onSaved: (value) => _password = value!,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your password'
                                        : null,
                              ),
                              Divider(),
                              SizedBox(height: 30),

                              // Login button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () => _login(context),
                              ),
                              SizedBox(height: 20), // Add some space
// Redirect to Register page button
                              TextButton(
                                child: Text(
                                    'Don\'t have an account? Register here'),
                                onPressed: () {
                                  // Navigate to RegisterPage
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => RegisterPage()));
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .primaryColor, // Button text color
                                ),
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                child: Text(
                                  'Continue without login',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Zen Dots'),
                                ),
                                onPressed: () {
                                  // Navigate to WelcomeScreen without user details
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Wel() // Pass null as user details
                                        ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Colors.white, // Button text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetail {
  final String? displayName;
  final String? email;

  UserDetail({this.displayName, this.email});
}
