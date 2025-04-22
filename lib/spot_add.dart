import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

class PlaceInputPage extends StatefulWidget {
  @override
  _AddTourPlacePageState createState() => _AddTourPlacePageState();
}

class _AddTourPlacePageState extends State<PlaceInputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _placeDetailsController = TextEditingController();
  final TextEditingController _placeAddressController = TextEditingController();
  final TextEditingController _placeCategoryController =
      TextEditingController();
  String? _selectedCategory;
  List<Uint8List> _imageBytesList = []; // Used for web image display
  List<File> _placeImagesList = []; // Used for mobile image display
  final ImagePicker _picker = ImagePicker();
  final Uuid uuid = Uuid();

  final List<String> _categories = [
    'Beach',
    'Garden',
    'Adventure',
    'Temple',
    'Cultural'
    // Add more categories as needed
  ];
  void _clearFormFields() {
    _placeNameController.clear();
    _placeDetailsController.clear();
    _placeAddressController.clear();
    _placeCategoryController.clear();
    setState(() {
      _placeImagesList.clear();
      _imageBytesList.clear();
    });
  }

  void submitData() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      List<String> imageUrlList = await uploadImages(
          kIsWeb ? _imageBytesList : _placeImagesList,
          kIsWeb ? 'web' : 'mobile');

      await FirebaseFirestore.instance.collection('place').add({
        'placeName': _placeNameController.text,
        'placeDetails': _placeDetailsController.text,
        'placeAddress': _placeAddressController.text,
        'placeCategory': _placeCategoryController.text,
        'placeImages': imageUrlList,
      });

      Navigator.pop(context); // Dismiss the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tour place added successfully')));
      _clearFormFields();
    }
  }

  // Other methods like _pickImages, uploadImages, submitData, _clearFormFields
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        if (kIsWeb) {
          Uint8List? bytes = await file.readAsBytes();
          _imageBytesList.add(bytes);
        } else {
          _placeImagesList.add(File(file.path));
        }
      }
      setState(() {});
    }
  }

  Future<List<String>> uploadImages(
      List<dynamic> images, String platform) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = 'place_images/${uuid.v4()}.png';
      FirebaseStorage storage =
          FirebaseStorage.instanceFor(bucket: 'gs://last-7892e.appspot.com');
      try {
        Uint8List imageBytes =
            kIsWeb ? image : await File(image.path).readAsBytes();
        TaskSnapshot snapshot = await storage.ref('uploads/$fileName').putData(
              imageBytes,
              SettableMetadata(contentType: 'image/png'),
            );
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Tour Place',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 35, 43, 49), // AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextFormField(
                    _placeNameController, 'Place Name', Icons.location_city),
                SizedBox(height: 10),
                buildTextFormField(_placeDetailsController, 'Place Details',
                    Icons.description),
                SizedBox(height: 10),
                buildTextFormField(
                    _placeAddressController, 'Place Address', Icons.map),
                SizedBox(height: 10),
                buildCategoryDropdown(),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text(
                    'Add Images',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 33, 30)),
                ),
                SizedBox(height: 20),
                _imagePreview(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      submitData();
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 34, 41)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 32, 47, 45)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.teal.shade50,
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Place Category',
        prefixIcon:
            Icon(Icons.category, color: const Color.fromARGB(255, 34, 44, 43)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.teal.shade50,
        filled: true,
      ),
      value: _selectedCategory,
      items: _categories.map((String category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _imagePreview() {
// For web, display images as bytes; for mobile, display as files
    return kIsWeb ? buildWebImagePreview() : buildMobileImagePreview();
  }

  Widget buildWebImagePreview() {
    return _imageBytesList.isNotEmpty
        ? buildImageListView(
            children: _imageBytesList
                .map((bytes) => Image.memory(bytes, width: 100, height: 100))
                .toList(),
          )
        : buildPlaceholderImage();
  }

  Widget buildMobileImagePreview() {
    return _placeImagesList.isNotEmpty
        ? buildImageListView(
            children: _placeImagesList
                .map((file) => Image.file(file, width: 100, height: 100))
                .toList(),
          )
        : buildPlaceholderImage();
  }

  Widget buildImageListView({required List<Widget> children}) {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: children
            .map((widget) =>
                Padding(padding: EdgeInsets.all(4.0), child: widget))
            .toList(),
      ),
    );
  }

  Widget buildPlaceholderImage() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 184, 208, 208),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 33, 41, 40)),
      ),
      child: Icon(Icons.camera_alt, color: Colors.teal.shade300, size: 50),
      alignment: Alignment.center,
    );
  }

// Implement submitData and other methods...
}
