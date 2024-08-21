import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navigator/models/location_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LocationModel>> fetchLocations() async {
    final snapshot = await _firestore.collection('locations').get();
    return snapshot.docs.map((doc) {
      return LocationModel.fromFirestore(doc.data());
    }).toList();
  }
}
