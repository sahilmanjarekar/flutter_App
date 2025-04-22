import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _username = '';
  String _email = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // ignore: unused_local_variable
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _passwordController.text,
        );
        // User registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Welcome, $_username!'),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally, navigate the user to a different page after successful registration
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      } on FirebaseAuthException catch (e) {
        // Handle Firebase registration error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: ${e.message}'),
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "image/nattu-adnan-Ai2TRdvI6gM-unsplash.jpg"), // Replace with your actual image path
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
                      "image/download__1_-removebg-preview (1).png"), // Ensure this path is correct
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
                                decoration: InputDecoration(
                                  icon: Icon(Icons.person),
                                  labelText: 'Username',
                                  border: InputBorder.none,
                                ),
                                onSaved: (value) => _username = value!,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a username'
                                    : null,
                              ),
                              Divider(),
                              TextFormField(
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
                                validator: (value) => value != null &&
                                        value.length < 6
                                    ? 'Password must be at least 6 characters long'
                                    : null,
                              ),
                              Divider(),

                              // Confirm Password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock_outline),
                                  labelText: 'Confirm Password',
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                validator: (value) =>
                                    value != _passwordController.text
                                        ? 'Passwords do not match'
                                        : null,
                              ),
                              SizedBox(height: 30),

                              // Register button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                ),
                                child: Text('Register',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: _register,
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
