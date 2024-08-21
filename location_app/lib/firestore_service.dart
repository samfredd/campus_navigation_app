import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_app/loc.dart';

class FirestoreService {
  final CollectionReference _locationsCollection =
      FirebaseFirestore.instance.collection('locations');

  Future<void> saveLocation(LocationModel location) async {
    await _locationsCollection.doc(location.id).set(location.toMap());
  }

  Future<List<LocationModel>> fetchLocations() async {
    QuerySnapshot snapshot = await _locationsCollection.get();
    return snapshot.docs.map((doc) => LocationModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
