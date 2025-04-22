import 'dart:io';
import 'package:final_project/login/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  final UserDetail userDetail;

  AccountPage(this.userDetail);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late SharedPreferences _prefs;
  late String _profileImageUrl;
  late String _username;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    final String userEmail = widget.userDetail.email ?? 'default';
    final String profileImageKey = 'profileImageUrl_$userEmail';
    final String usernameKey = 'username_$userEmail';
    setState(() {
      _profileImageUrl = _prefs.getString(profileImageKey) ?? 'default';
      _username = _prefs.getString(usernameKey) ?? 'Guest';
    });
  }

  // Method to handle image selection
  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final String userEmail = widget.userDetail.email ?? 'default';
      final String profileImageKey = 'profileImageUrl_$userEmail';
      setState(() {
        _profileImageUrl = image.path;
        _prefs.setString(profileImageKey, _profileImageUrl);
      });
    }
  }

  // Method to handle username update
  void _updateUsername(String newUsername) {
    final String userEmail = widget.userDetail.email ?? 'default';
    final String usernameKey = 'username_$userEmail';
    setState(() {
      _username = newUsername;
      _prefs.setString(usernameKey, _username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl.isNotEmpty &&
                        File(_profileImageUrl).existsSync()
                    ? FileImage(File(_profileImageUrl)) as ImageProvider<
                        Object> // Explicitly cast to ImageProvider<Object>
                    : AssetImage('assets/placeholder_image.jpg'),
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _username,
              style: TextStyle(
                fontSize: 20,
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.userDetail.email ?? 'No email provided',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _username,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              onChanged: _updateUsername,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement logout functionality
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
