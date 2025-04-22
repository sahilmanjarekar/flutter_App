import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  double? lat;

  double? long;

  String address = "";
  bool isLoading = false;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getLatLong() {
    Future<Position> data = _determinePosition();
    data.then((value) {
      print("value $value");
      setState(() {
        lat = value.latitude;
        long = value.longitude;
      });

      getAddress(value.latitude, value.longitude);
    }).catchError((error) {
      print("Error $error");
    });
  }

//For convert lat long to address
  getAddress(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String result = '';

      if (place.locality != null && place.locality!.isNotEmpty) {
        result += place.locality! + ", ";
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        result += place.administrativeArea! + ", ";
      }
      if (place.country != null && place.country!.isNotEmpty) {
        result += place.country!;
      }

      // Remove any trailing commas and spaces
      result = result.endsWith(', ')
          ? result.substring(0, result.length - 2)
          : result;

      setState(() {
        address = result;
      });

      // Debug print for all placemarks
      for (int i = 0; i < placemarks.length; i++) {
        print("INDEX $i: ${placemarks[i]}");
      }
    } else {
      setState(() {
        address = "No address available";
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
        title: Text("Location Details",
            style: TextStyle(color: Colors.amberAccent)),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 100, color: Colors.indigo[900]),
                  SizedBox(height: 20),
                  Text("Latitude: $lat",
                      style:
                          TextStyle(fontSize: 20, color: Colors.indigo[900])),
                  SizedBox(height: 10),
                  Text("Longitude: $long",
                      style:
                          TextStyle(fontSize: 20, color: Colors.indigo[900])),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Address: $address",
                      style: TextStyle(fontSize: 18, color: Colors.indigo[900]),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: getLatLong,
                    child: Text("Refresh Location"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.amber[800],
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
