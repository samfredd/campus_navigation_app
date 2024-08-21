import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DirectionsService {
  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final coordinates = decodedData['routes'][0]['geometry']['coordinates'];
      return coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<List<Map<String, dynamic>>> getTurnInstructions(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final steps = decodedData['routes'][0]['legs'][0]['steps'];
      return steps.map<Map<String, dynamic>>((step) {
        return {
          'instruction': step['maneuver']['instruction'],
          'distance': step['distance']
        };
      }).toList();
    } else {
      throw Exception('Failed to load turn instructions');
    }
  }
}
