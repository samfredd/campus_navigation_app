import 'package:latlong2/latlong.dart';

class LocationModel {
  final LatLng position;
  final String name;

  LocationModel(this.position, this.name);

  factory LocationModel.fromFirestore(Map<String, dynamic> data) {
    return LocationModel(
      LatLng(data['latitude'], data['longitude']),
      data['name'],
    );
  }
}
