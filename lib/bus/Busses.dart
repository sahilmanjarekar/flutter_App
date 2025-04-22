import 'package:final_project/bus/input.dart';
import 'package:final_project/bus/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BussesPage extends StatefulWidget {
  @override
  _BussesPageState createState() => _BussesPageState();
}

class _BussesPageState extends State<BussesPage> {
  final CollectionReference bus = FirebaseFirestore.instance.collection('bus');
  List<Map<String, dynamic>> allBuses = [];
  List<Map<String, dynamic>> filteredBuses = [];
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bus.snapshots().listen((snapshot) {
      allBuses = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _filterBuses();
    });
  }

  void _filterBuses() {
    final fromQuery = _fromController.text.toLowerCase();
    final toQuery = _toController.text.toLowerCase();
    setState(() {
      filteredBuses = allBuses.where((bus) {
        final fromLower = bus['from'].toString().toLowerCase();
        final toLower = bus['to'].toString().toLowerCase();
        return fromLower.contains(fromQuery) && toLower.contains(toQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Widget _buildSearchBox(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        onChanged: (value) => _filterBuses(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus TimeTable',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 21, 9, 0),
      ),
      body: Column(
        children: [
          _buildSearchBox(_fromController, 'From', 'Enter start location'),
          _buildSearchBox(_toController, 'To', 'Enter destination'),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBuses.length,
              itemBuilder: (context, index) {
                var busDetail = filteredBuses[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 14, 11, 24),
                      child: Icon(Icons.directions_bus,
                          color: Color.fromARGB(255, 237, 11, 11)),
                    ),
                    title: Text('${busDetail['from']} → ${busDetail['to']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Departs at: ${busDetail['Start_time']}'),
                        Text('Arrives by: ${busDetail['End_time']}'),
                        Text('Distance: ${busDetail['kilometer']} km'),
                      ],
                    ),
                    trailing: busDetail['status'] != null
                        ? Chip(
                            label: Text(busDetail['status']),
                            backgroundColor: Colors.orangeAccent,
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutePage(
                            trip_number: busDetail['trip_number'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }
}

// Keep your BusSearchDelegate class here if you use it elsewhere in the app

class BusSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> allBuses;
  final Function updateFilter;

  BusSearchDelegate(this.allBuses, this.updateFilter);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    updateFilter();
    // Build results based on the search query
    return Container(); // Replace with your result widget
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allBuses.where((bus) {
      return bus['from'].toLowerCase().contains(query.toLowerCase()) ||
          bus['to'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var busDetail = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                const Color.fromARGB(255, 14, 11, 24), // Updated color
            child: Icon(Icons.directions_bus,
                color: const Color.fromARGB(255, 237, 11, 11)),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${busDetail['from']} → ${busDetail['to']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Departs at: ${busDetail['Start_time']}'),
                Text('Arrives by: ${busDetail['End_time']}'),
                Text('Distance: ${busDetail['kilometer']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
