import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'marker_provider.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  LatLng _currentPosition = LatLng(51.5, -0.09);
  late Marker _currentLocationMarker;
  final MapController _mapController = MapController();
  late StreamSubscription<Position> _positionStreamSubscription;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentLocationMarker = Marker( 
      point: _currentPosition,
      builder: (ctx) =>
          const Icon(Icons.person_pin_circle, color: Colors.red, size: 50),
    );
    _initializeLocationTracking();
    _updateMarkers();
  }

  Future<void> _initializeLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage('Location permissions are permanently denied.');
      return;
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentLocationMarker = Marker(
            point: _currentPosition,
            builder: (ctx) => const Icon(Icons.person_pin_circle,
                color: Colors.red, size: 50),
          );
          _mapController.move(_currentPosition, 18.5);
        });
      });
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _saveCurrentLocation() async {
    final name = await _promptForLocationName();
    if (name != null) {
      final markerProvider =
          Provider.of<MarkerProvider>(context, listen: false);
      await markerProvider.saveMarker(_currentPosition, name);
      _updateMarkers();
    }
  }

  Future<String?> _promptForLocationName() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String locationName = '';
        return AlertDialog(
          title: const Text('Enter Location Name'),
          content: TextField(
            onChanged: (value) {
              locationName = value;
            },
            decoration: const InputDecoration(hintText: "Location Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(locationName);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMarkers() async {
    final markerProvider = Provider.of<MarkerProvider>(context, listen: false);
    await markerProvider.loadMarkers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final markerProvider = Provider.of<MarkerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_currentPosition, 18.5);
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _saveCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.pushNamed(context, '/saved_locations');
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentPosition,
          zoom: 13.0,
          onTap: (tapPosition, point) async {
            final name = await _promptForLocationName();
            if (name != null) {
              final markerProvider =
                  Provider.of<MarkerProvider>(context, listen: false);
              await markerProvider.saveMarker(point, name);
              _updateMarkers();
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=sk.eyJ1Ijoic2FtZnJlZHgiLCJhIjoiY2x6c2ZkZmNmMjBrbTJrcjQ3cm0wNmtiYSJ9.nD0IPjT50an-7eQF15itJA",
            additionalOptions: const {
              'accessToken':
                  'sk.eyJ1Ijoic2FtZnJlZHgiLCJhIjoiY2x6c2ZkZmNmMjBrbTJrcjQ3cm0wNmtiYSJ9.nD0IPjT50an-7eQF15itJA',
            },
          ),
          MarkerLayer(
            markers: [
              _currentLocationMarker,
              ...markerProvider.markers.map((markerData) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: markerData.position,
                  builder: (ctx) => Column(
                    children: [
                      Text(markerData.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 40),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
