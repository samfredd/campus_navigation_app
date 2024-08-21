import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MarkerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Set<Marker>> getMarkers() async {
    final snapshot = await _firestore.collection('markers').get();
    final markers = <Marker>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final position = data['position'];

      final marker = Marker(
        point: LatLng(position['latitude'], position['longitude']),
        builder: (ctx) =>
            const Icon(Icons.location_on, color: Colors.red, size: 40),
      );

      markers.add(marker);
    }

    return markers;
  }

  Future<void> saveMarker(LatLng position) async {
    await _firestore.collection('markers').add({
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    });
    notifyListeners();
  }

  Future<void> deleteMarker(String markerId) async {
    await _firestore.collection('markers').doc(markerId).delete();
    notifyListeners();
  }

  Future<void> addMarkerAtUserLocation() async {
    LatLng userLocation = await getUserLocation();
    await saveMarker(userLocation);
  }

  Future<LatLng> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When permissions are granted, get the current position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }
}
