import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_app/firestore_service.dart';
import 'package:location_app/loc.dart';
import 'package:uuid/uuid.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  AddLocationPageState createState() => AddLocationPageState();
}

class AddLocationPageState extends State<AddLocationPage> {
  final _nameController = TextEditingController();
  final _firestoreService = FirestoreService();

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  void _saveLocation() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current location not available')));
      return;
    }

    final id = const Uuid().v4();
    final name = _nameController.text;
    final latitude = _currentPosition!.latitude;
    final longitude = _currentPosition!.longitude;

    final location = LocationModel(
        id: id, name: name, latitude: latitude, longitude: longitude);
    _firestoreService.saveLocation(location);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Location saved!')));
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
            const SizedBox(height: 20),
            Text(
              _currentPosition != null
                  ? 'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}'
                  : 'Fetching current location...',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLocation,
              child: const Text('Save Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}
