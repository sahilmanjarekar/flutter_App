import 'dart:io';
import 'dart:typed_data';
import 'package:final_project/fullscreenimage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(MaterialApp(
      home: bestplacepage(
        spotId: 'your-spot-id',
        documentId: '',
      ),
    ));

class bestplacepage extends StatefulWidget {
  final String spotId;

  bestplacepage({Key? key, required this.spotId, required String documentId})
      : super(key: key);

  @override
  _SpotPageState createState() => _SpotPageState();
}

Stream<QuerySnapshot> _fetchFeedback(String spotId) {
  return FirebaseFirestore.instance
      .collection('feedback')
      .where('spotId', isEqualTo: spotId)
      // Filter by spotId
      .snapshots();
}

double calculateAverageRating(List<Map<String, dynamic>> feedbackItems) {
  if (feedbackItems.isEmpty) {
    // Return a default rating if there is no feedback
    return 4.5;
  }

  // Calculate the average rating
  double totalRating =
      feedbackItems.fold(0, (sum, feedback) => sum + feedback['rating']);
  return totalRating / feedbackItems.length;
}

class _SpotPageState extends State<bestplacepage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _currentRating = 0;
  XFile? _imageFile; // For storing picked image file
  List<Map<String, dynamic>> _feedbackList = []; // Local list to store feedback

  Future<List<String>> _uploadImage(List<dynamic> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName =
          'feedback_images/${Uuid().v4()}.png'; // Using Uuid to generate unique filenames
      FirebaseStorage storage =
          FirebaseStorage.instanceFor(bucket: 'gs://last-7892e.appspot.com');
      try {
        Uint8List imageBytes =
            kIsWeb ? image : await File(image.path).readAsBytes();
        TaskSnapshot snapshot = await storage.ref(fileName).putData(
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

  void _submitFeedback({
    required BuildContext context,
    required String text,
    required double rating,
    String? imageUrl,
  }) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve the user email
      String? userEmail = user.email;

      // Associate the user email with the feedback data
      Map<String, dynamic> feedbackData = {
        'spotId': widget.spotId,
        'text': text,
        'rating': rating,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': userEmail, // Associate the user email with the feedback
      };

      try {
        // Store the feedback data in Firestore
        await FirebaseFirestore.instance
            .collection('feedback')
            .add(feedbackData);

        // Show a dialog to inform the user about successful submission
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Feedback Submitted'),
              content: Text('Thank you for your feedback!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } else {
      // Handle the case when the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated.')),
      );
    }
  }

  void _addFeedbackToLocalList(Map<String, dynamic> feedback) {
    setState(() {
      _feedbackList.insert(0, {
        'text': feedback['text'],
        'rating': feedback['rating'],
        'timestamp': DateTime.now(),
        'imageUrl': feedback['imageUrl'],
      });
    });
  }

  Future<DocumentSnapshot> _fetchSpotDetails() async {
    return FirebaseFirestore.instance
        .collection('bestplace')
        .doc(widget.spotId)
        .get();
  }

  @override
  void dispose() {
    // Dispose controllers when the state is disposed.
    _feedbackController.dispose();
    super.dispose();
  }

  // Add this at the class level
  void _showFeedbackDialog() {
    String? imageUrl; // For storing image URL

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // This is needed to update the dialog's content
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Feedback'),
              content: SingleChildScrollView(
                // Use a SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Leave your feedback...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    Text('Rate this spot:'),
                    Slider(
                      value: _currentRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _currentRating.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentRating = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    OutlinedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text('Add Image'),
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          _imageFile = image; // Store the picked image file
                          setState(
                              () {}); // Update the UI to show image preview
                        }
                      },
                    ),
                    if (_imageFile != null) // Show the selected image preview
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.file(File(_imageFile!.path),
                            height: 100), // Display the image
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    // Upload image to Firebase Storage and get download URL
                    if (_imageFile != null) {
                      List<String> imageUrls =
                          await _uploadImage([File(_imageFile!.path)]);
                      imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
                    }
                    // Submit feedback with image URL
                    _submitFeedback(
                      context: context,
                      text: _feedbackController.text,
                      imageUrl: imageUrl,
                      rating: _currentRating,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageGallery(
      BuildContext context, List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: images
              .map((image) => PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(image),
                    minScale: PhotoViewComputedScale.contained,
                  ))
              .toList(),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildFeedbackList(String? currentUserEmail) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fetchFeedback(widget.spotId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Map<String, dynamic>> feedbackItems =
            snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'text': data['text'] ?? 'No feedback',
            'rating': data['rating'] ?? 0,
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
            'imageUrl': data['imageUrl'], // This could be null
            'userEmail':
                data['userEmail'], // Add user email to the feedback item
          };
        }).toList();

        feedbackItems.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        return ListView.builder(
          shrinkWrap: true,
          itemCount: feedbackItems.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> feedback = feedbackItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feedback['imageUrl'] != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(imageUrl: feedback['imageUrl']),
                        ),
                      );
                    },
                    child: Image.network(
                      feedback['imageUrl'],
                      width: 100,
                      // Add other image properties as needed
                    ),
                  ),

                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20.0),
                    SizedBox(width: 4.0),
                    Text(
                      '${feedback['rating']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Text('Description: ${feedback['text']}'),
                Text(
                  'Date & Time: ${feedback['timestamp']}',
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  'User Email: ${feedback['userEmail']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(), // Add divider between feedback items
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageGrid(List<dynamic> images) {
    // Assuming the first image is the cover image
    List<dynamic> gridImages = images.sublist(1);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: gridImages.length,
      itemBuilder: (context, index) {
        String image = gridImages[index];
        return GestureDetector(
          onTap: () => _showImageGallery(
              context, images, index + 1), // +1 to adjust for cover image
          child: Hero(
            tag: 'spot_image_$index',
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(
                    10), // Rounded corners for the grid images
              ),
            ),
          ),
        );
      },
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchSpotDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No Spot Data Available'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> images = data['placeImages'] ?? [];
          List<Map<String, dynamic>> feedbackItems =
              _feedbackList; // Use the local list of feedback
          double rating = calculateAverageRating(feedbackItems);
          String title = data['placeName'] ?? 'Place Name';
          String description = data['placeDetails'] ?? 'description';

          // Retrieve current user's email
          String? currentUserEmail = getCurrentUserEmail();

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    images.isNotEmpty
                        ? images[0]
                        : 'https://via.placeholder.com/400x200',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 24.0),
                          SizedBox(width: 4.0),
                          Text(
                            '$rating',
                            style: TextStyle(fontSize: 24.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        description,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                      _buildImageGrid(images),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildFeedbackList(
                    currentUserEmail), // Pass currentUserEmail
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFeedbackDialog,
        tooltip: 'Feedback',
        child: Icon(Icons.feedback),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    Key? key,
    required this.galleryItems,
    this.backgroundDecoration,
    this.initialIndex,
  })  : pageController = PageController(initialPage: initialIndex ?? 0),
        super(key: key);

  final List<PhotoViewGalleryPageOptions> galleryItems;
  final BoxDecoration? backgroundDecoration;
  final int? initialIndex;
  final PageController pageController;

  @override
  _GalleryPhotoViewWrapperState createState() =>
      _GalleryPhotoViewWrapperState();
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = widget.initialIndex ?? 0;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            widget.backgroundDecoration ?? BoxDecoration(color: Colors.black),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return widget.galleryItems[index];
              },
              itemCount: widget.galleryItems.length,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                "Image ${currentIndex + 1} / ${widget.galleryItems.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
