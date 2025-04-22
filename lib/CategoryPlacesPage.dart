import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/spot.dart';
import 'package:flutter/material.dart';

class CategoryPlacesPage extends StatelessWidget {
  final String category;

  CategoryPlacesPage({Key? key, required this.category}) : super(key: key);

  Stream<QuerySnapshot> get placesStream {
    return FirebaseFirestore.instance
        .collection('place')
        .where('placeCategory', isEqualTo: category)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: placesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No places found for this category.'));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10, // Horizontal space between cards
              mainAxisSpacing: 10, // Vertical space between cards
              childAspectRatio: 0.8, // Aspect ratio of the cards
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String placeName = data['placeName'] ?? 'Unnamed Place';
              List<dynamic> placeImages = data['placeImages'] ?? [];

              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black45,
                    title: Text(
                      placeName,
                      style: TextStyle(fontSize: 16),
                    ),
                    // Add trailing or leading widgets if necessary
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SpotPage(
                                  spotId: doc.id,
                                  documentId: '',
                                )),
                      );
                    },
                    child: placeImages.isNotEmpty
                        ? Image.network(placeImages.first, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.image,
                                size: 50, color: Colors.white30),
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
