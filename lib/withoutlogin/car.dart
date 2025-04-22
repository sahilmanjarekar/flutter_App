import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class cp extends StatefulWidget {
  @override
  _CarsPageState createState() => _CarsPageState();
}

class _CarsPageState extends State<cp> {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cars",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 10, 17),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Address or Car Name',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to filter results
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('car').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data?.docs ?? [];

                // Filter documents based on the search query
                var filteredDocs = docs.where((doc) {
                  var car = doc.data() as Map<String, dynamic>;
                  var matchesName = car['carName']
                      .toString()
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());
                  var matchesAddress = car['address']
                      .toString()
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());
                  return matchesName || matchesAddress;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text("No cars found."));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var document = filteredDocs[index];
                    var car = document.data() as Map<String, dynamic>;

                    String carImageUrl = car['carImage'] ?? '';
                    String carName = car['carName'] ?? 'Unknown Car Name';

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          // Handle tap: Show car details
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(carName),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      carImageUrl.isNotEmpty
                                          ? Image.network(
                                              carImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(Icons.error,
                                                      color: Colors.grey,
                                                      size: 100),
                                            )
                                          : Icon(Icons.directions_car,
                                              color: Colors.grey, size: 100),
                                      SizedBox(height: 8),
                                      Text(
                                          'Owner: ${car['ownerName'] ?? 'N/A'}'),
                                      Row(
                                        children: [
                                          Text(
                                              'Contact: ${car['ownerContact'] ?? 'N/A'}'),
                                          IconButton(
                                            icon: Icon(
                                              Icons.call,
                                            ), // Use the call icon
                                            onPressed: () {
                                              final String? ownerContact =
                                                  car['ownerContact'];
                                              if (ownerContact != null) {
                                                launch(
                                                    'tel:$ownerContact'); // Launch the phone app
                                              } else {
                                                // Handle case when owner contact is not available
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Owner Contact Not Available'),
                                                      content: Text(
                                                          'The owner contact number is not available.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(
                                          'Car Number: ${car['carNumber'] ?? 'N/A'}'),
                                      Text(
                                          'Address: ${car['address'] ?? 'N/A'}'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: carImageUrl.isNotEmpty
                                  ? Image.network(
                                      carImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.error,
                                              color: Colors.grey,
                                              size: 100),
                                    )
                                  : Icon(Icons.directions_car,
                                      color: Colors.grey, size: 100),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                carName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
