import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class MarkerData {
  final String id; // Unique ID for each marker
  final LatLng position;
  final String name;

  MarkerData({required this.id, required this.position, required this.name});
}

class MarkerProvider extends ChangeNotifier {
  List<MarkerData> _markers = [];

  List<MarkerData> get markers => _markers;

  final CollectionReference _locationsCollection = FirebaseFirestore.instance.collection('locations');

  Future<void> saveMarker(LatLng position, String name) async {
    await _locationsCollection.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'name': name,
    });
    await loadMarkers();
  }

  Future<void> loadMarkers() async {
    final snapshot = await _locationsCollection.get();
    _markers = snapshot.docs.map((doc) {
      return MarkerData(
        id: doc.id, // Store the document ID for deletion
        position: LatLng(doc['latitude'], doc['longitude']),
        name: doc['name'],
      );
    }).toList();
    notifyListeners();
  }

  Future<void> deleteMarker(MarkerData marker) async {
    await _locationsCollection.doc(marker.id).delete();
    _markers.remove(marker);
    notifyListeners();
  }
}
