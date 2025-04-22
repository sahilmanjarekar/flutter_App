import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoutePage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String trip_number;

  RoutePage({Key? key, required this.trip_number}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final CollectionReference busStopsCollection =
      FirebaseFirestore.instance.collection('busStops');
  final TextEditingController _stopNameController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  String from = '';
  String to = '';

  @override
  void initState() {
    super.initState();
    _fetchRouteDetails();
  }

  Future<void> _fetchRouteDetails() async {
    try {
      var routeSnapshot = await FirebaseFirestore.instance
          .collection('routes')
          .doc(widget.trip_number)
          .get();
      if (routeSnapshot.exists) {
        setState(() {
          from = routeSnapshot['from'];
          to = routeSnapshot['to'];
        });
      }
    } catch (e) {
      print('Error fetching route details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Stops",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(
            255, 1, 8, 13), // Customize the background color
        elevation: 0, // Remove the shadow
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: busStopsCollection
            .where('trip_number', isEqualTo: widget.trip_number)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          var stops = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['stop_name']),
              subtitle: Text('Arrival Time: ${data['arrival_time']}'),
            );
          }).toList();
          return ListView(children: stops);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStopDialog(context),
        child: Icon(
          Icons.add,
          color: Color.fromARGB(255, 253, 253, 253),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  void _showAddStopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Stop'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _stopNameController,
                  decoration: InputDecoration(hintText: "Stop Name"),
                ),
                TextField(
                  controller: _arrivalTimeController,
                  decoration: InputDecoration(hintText: "Arrival Time"),
                  keyboardType: TextInputType.datetime,
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
              child: Text('Add'),
              onPressed: () => _addNewStop(context),
            ),
          ],
        );
      },
    );
  }

  void _addNewStop(BuildContext context) async {
    if (_stopNameController.text.isNotEmpty &&
        _arrivalTimeController.text.isNotEmpty) {
      // Generate a unique ID for the new stop
      String stopId = busStopsCollection.doc().id;

      await busStopsCollection.add({
        'stop_id': stopId, // Add the stop_id field
        'stop_name': _stopNameController.text,
        'arrival_time': _arrivalTimeController.text,
        'trip_number': widget.trip_number,
      });

      _stopNameController.clear();
      _arrivalTimeController.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Stop added successfully!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
    }
  }
}
