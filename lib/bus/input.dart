// ignore: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  CollectionReference bus = FirebaseFirestore.instance.collection('bus');
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  // final _numberController = TextEditingController();

  // final _tripController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _kilometerController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _kilometerController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Enter Trip Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  // Optionally add an icon or image
                  Icon(Icons.directions_bus,
                      size: 100, color: Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _fromController,
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter start point';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _toController,
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter destination';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _kilometerController,
                    decoration: InputDecoration(
                      labelText: 'Kilometer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timeline),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter distance in kilometers';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter start time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter end time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Create a new document reference without specifying an ID
                          DocumentReference newDocument = widget.bus.doc();

                          // Add data to Firestore including the automatically generated ID
                          await newDocument.set({
                            'trip_number':
                                newDocument.id, // Automatically generated ID
                            'from': _fromController.text,
                            'to': _toController.text,
                            'kilometer': _kilometerController.text,
                            'Start_time': _startTimeController.text,
                            'End_time': _endTimeController.text,
                          });

                          // Clear all the fields after successful submission
                          _fromController.clear();
                          _toController.clear();
                          _kilometerController.clear();
                          _startTimeController.clear();
                          _endTimeController.clear();

                          // Show a SnackBar upon successful submission
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Data submitted successfully'),
                              backgroundColor:
                                  Color.fromARGB(255, 109, 206, 109),
                            ),
                          );
                        } catch (e) {
                          // Handle the error, maybe show a user-friendly error message.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to submit data: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
