import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CarInputPage extends StatefulWidget {
  @override
  _CarInputPageState createState() => _CarInputPageState();
}

class _CarInputPageState extends State<CarInputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Uint8List? _imageBytes; // Used for web image display
  File? _carImage; // Used for mobile image display
  final ImagePicker _picker = ImagePicker();
// Used for web image display
// Used for mobile image display

  @override
  void dispose() {
    _carNameController.dispose();
    _ownerNameController.dispose();
    _carNumberController.dispose();
    _ownerContactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _imageBytes = await pickedFile.readAsBytes();
      } else {
        _carImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  Future<String?> uploadImage() async {
    if (kIsWeb) {
      if (_imageBytes != null) {
        return await uploadImageToFirebase(_imageBytes!, 'web');
      }
    } else {
      if (_carImage != null) {
        Uint8List imageBytes = await _carImage!.readAsBytes();
        return await uploadImageToFirebase(imageBytes, 'mobile');
      }
    }
    return null; // Return null if there's no image to upload
  }

  // Unified image upload function for both web and mobile
  Future<String?> uploadImageToFirebase(
      Uint8List imageBytes, String platform) async {
    String fileName = 'car_images/${DateTime.now().millisecondsSinceEpoch}.png';
    FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'gs://last-7892e.appspot.com');
    try {
      TaskSnapshot snapshot = await storage.ref('uploads/$fileName').putData(
            imageBytes,
            SettableMetadata(contentType: 'image/png'),
          );
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  void submitData() async {
    if (_formKey.currentState!.validate()) {
      // Start showing a loading indicator
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      String? imageUrl =
          await uploadImage(); // Updated to use the new unified function

      // Proceed to add data to Firestore only if image upload succeeds or there's no image
      if (imageUrl != null || (_imageBytes == null && _carImage == null)) {
        await FirebaseFirestore.instance.collection('car').add({
          'carName': _carNameController.text,
          'ownerName': _ownerNameController.text,
          'carNumber': _carNumberController.text,
          'ownerContact': _ownerContactController.text,
          'address': _addressController.text,
          'carImage':
              imageUrl ?? "", // Use the uploaded image URL or an empty string
        });
        // Data added successfully, show a snackbar and clear the form
        Navigator.pop(context); // Dismiss the loading indicator
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Car added successfully')));
        _clearFormFields();
      } else {
        // Image upload failed, show a snackbar
        Navigator.pop(context); // Dismiss the loading indicator
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to upload image')));
      }
    }
  }

  void _clearFormFields() {
    _carNameController.clear();
    _ownerNameController.clear();
    _carNumberController.clear();
    _ownerContactController.clear();
    _addressController.clear();
    setState(() {
      _carImage = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Car',
          style: TextStyle(color: Colors.cyan),
        ),
        backgroundColor:
            const Color.fromARGB(255, 7, 5, 11), // Enhanced AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextField(
                    _carNameController, 'Car Name', Icons.directions_car),
                buildTextField(
                    _ownerNameController, 'Owner Name', Icons.person),
                buildTextField(_carNumberController, 'Car Number',
                    Icons.confirmation_number),
                buildTextField(_ownerContactController, 'Owner Contact Number',
                    Icons.phone,
                    isNumber: true),
                buildTextField(
                    _addressController, 'Owner Address', Icons.location_on),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: _imagePreview(),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: submitData,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 4, 197, 241),
                    backgroundColor: Color.fromARGB(255, 0, 0, 0), // Text color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _imagePreview() {
    Widget placeholder = Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.camera_alt, color: Colors.grey[700], size: 50),
    );

    if (kIsWeb) {
      return _imageBytes != null
          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
          : placeholder;
    } else {
      return _carImage != null
          ? Image.file(_carImage!, fit: BoxFit.cover)
          : placeholder;
    }
  }
}
