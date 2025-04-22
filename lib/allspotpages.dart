import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/CategoryPlacesPage.dart';
import 'package:final_project/HomeBottomBar.dart';
import 'package:final_project/home_app_bar.dart';
import 'package:final_project/spot.dart';
import 'package:final_project/spot_add.dart';
import 'package:final_project/spots.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: AllSpotsPage()));

class AllSpotsPage extends StatefulWidget {
  @override
  _AllSpotsPageState createState() => _AllSpotsPageState();
}

class _AllSpotsPageState extends State<AllSpotsPage> {
  String searchQuery = '';

  void _updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.trim().toLowerCase();
    });
  }

  Stream<QuerySnapshot> get placesStream {
    var collection = FirebaseFirestore.instance.collection('place');
    if (searchQuery.isNotEmpty) {
      return collection
          .where('placeAddress', isGreaterThanOrEqualTo: searchQuery)
          .where('placeAddress', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .snapshots();
    }
    return collection.snapshots();
  }

  Stream<QuerySnapshot> get bestPlacesStream {
    return FirebaseFirestore.instance.collection('bestplace').snapshots();
  }

  Widget _buildBestPlaceCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String placeImages;
    if (data['placeImages'] is List) {
      // Taking the first item if it's a list, but you should handle it as per your data structure.
      placeImages = (data['placeImages'] as List).isNotEmpty
          ? data['placeImages'][0]
          : 'https://via.placeholder.com/150';
    } else {
      placeImages = data['placeImages'] ?? 'https://via.placeholder.com/150';
    }
    String placeName = data['placeName'] ?? 'Unnamed Place';

    return InkWell(
      onTap: () {
        // Pass the document ID of the best place to the SpotPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => bestplacepage(
              spotId: doc.id,
              documentId: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: NetworkImage(placeImages),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              placeName,
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String placeImages;
    if (data['placeImages'] is List) {
      // Taking the first item if it's a list, but you should handle it as per your data structure.
      placeImages = (data['placeImages'] as List).isNotEmpty
          ? data['placeImages'][0]
          : 'https://via.placeholder.com/150';
    } else {
      placeImages = data['placeImages'] ?? 'https://via.placeholder.com/150';
    }
    String placeName = data['placeName'] ?? 'Unnamed Spot';

    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SpotPage(
                spotId: doc.id,
                documentId: '',
              ),
            ),
          );
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              placeImages.isNotEmpty
                  ? Image.network(
                      placeImages,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(child: Text('Image not available')),
                    )
                  : Center(child: Text('No image available')),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  placeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 233, 249, 253),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Beach',
      'Garden',
      'Adventure',
      'Temple',
      'Cultural'
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: HomeAppBar(), // Adjust if necessary
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search places by location...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onChanged: _updateSearchQuery,
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                "Nearest Places",
                style: TextStyle(
                  color: Color.fromARGB(255, 12, 15, 16),
                  fontSize: 20,
                  fontFamily: 'Zen Dots',
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: StreamBuilder<QuerySnapshot>(
                stream: placesStream, // Use the filtered stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No places available'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      return _buildSpotCard(doc);
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: FilterChip(
                      backgroundColor: const Color.fromARGB(255, 9, 15, 15),
                      label: Text(
                        categories[index],
                        style: TextStyle(
                          fontFamily: 'Zen Dots',
                          color: Colors.cyan,
                        ),
                      ),
                      onSelected: (bool value) {
                        if (value) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CategoryPlacesPage(
                                category: categories[index],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Text(
                "Best Places In Sindhudurg",
                style: TextStyle(
                  color: Color.fromARGB(255, 12, 15, 16),
                  fontSize: 20,
                  fontFamily: 'Zen Dots',
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: bestPlacesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Best Places Available'));
                }
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    return _buildBestPlaceCard(doc);
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(
        userEmail: 'userEmail',
        displayName: 'username',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlaceInputPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 224, 232, 231),
        tooltip: 'Add New Place',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
