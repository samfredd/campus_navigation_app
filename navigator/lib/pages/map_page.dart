import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:navigator/services/direction_services.dart';

class MapNavPage extends StatefulWidget {
  final LatLng end;
  final String destinationName;

  const MapNavPage(
      {super.key, required this.end, required this.destinationName});

  @override
  MapNavPageState createState() => MapNavPageState();
}

class MapNavPageState extends State<MapNavPage> {
  LatLng _currentPosition = LatLng(0, 0);
  List<LatLng> _route = [];
  double _distance = 0.0; // Distance to destination in meters
  final DirectionsService _directionsService = DirectionsService();
  final FlutterTts _flutterTts = FlutterTts();
  final MapController _mapController = MapController();
  Position? _lastPosition;
  double _currentHeading = 0.0;
  List<Map<String, dynamic>> _turnInstructions = [];
  int _currentInstructionIndex = 0;
  double _distanceToNextTurn = 0.0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5);
    _initNavigation();
  }

  Future<void> _initNavigation() async {
    await _getCurrentLocation();
    await _getRoute();
    _calculateDistance();
    _speakDestinationName();
    await _loadTurnInstructions();
    _listenToPositionChanges();
  }

  Future<void> _getCurrentLocation() async {
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
        _showMessage('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 15.0);
      });
    } catch (e) {
      _showMessage('Failed to get current location: $e');
    }
  }

  Future<void> _getRoute() async {
    try {
      _route = await _directionsService.getRouteCoordinates(
          _currentPosition, widget.end);
      setState(() {});
    } catch (e) {
      _showMessage('Failed to get route: $e');
    }
  }

  Future<void> _loadTurnInstructions() async {
    try {
      _turnInstructions = await _directionsService.getTurnInstructions(
          _currentPosition, widget.end);
      if (_turnInstructions.isNotEmpty) {
        _updateDistanceToNextTurn();
      }
    } catch (e) {
      _showMessage('Failed to load turn instructions: $e');
    }
  }

  void _listenToPositionChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) async {
      if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        LatLng newPosition = LatLng(position.latitude, position.longitude);
        _provideNavigationInstructions(newPosition);
        setState(() {
          _currentPosition = newPosition;
          _mapController.move(_currentPosition, 15.0);
          _updateHeading(newPosition);
        });
        _updateRoute(newPosition);
        _calculateDistance();
        _updateTurnInstructions(newPosition);
      });
    });
  }

  Future<void> _updateRoute(LatLng newPosition) async {
    try {
      _route =
          await _directionsService.getRouteCoordinates(newPosition, widget.end);
      setState(() {});
    } catch (e) {
      _showMessage('Failed to update route: $e');
    }
  }

  Future<void> _updateTurnInstructions(LatLng newPosition) async {
    if (_turnInstructions.isEmpty ||
        _currentInstructionIndex >= _turnInstructions.length) {
      return;
    }

    double distanceToNextTurn = _distanceToNextTurn;
    if (distanceToNextTurn <= 0) {
      _distanceToNextTurn = Geolocator.distanceBetween(
        newPosition.latitude,
        newPosition.longitude,
        _route[_currentInstructionIndex].latitude,
        _route[_currentInstructionIndex].longitude,
      );
      distanceToNextTurn = _distanceToNextTurn;
    }

    if (_distance < 100) {
      _flutterTts
          .speak(
              "Next turn: ${_turnInstructions[_currentInstructionIndex]['instruction']}")
          .catchError((e) {
        _showMessage('Failed to announce turn: $e');
      });
      setState(() {
        _currentInstructionIndex++;
        if (_currentInstructionIndex < _turnInstructions.length) {
          _updateDistanceToNextTurn();
        }
      });
    }
  }

  void _updateDistanceToNextTurn() {
    if (_currentInstructionIndex < _turnInstructions.length) {
      final nextTurn = _turnInstructions[_currentInstructionIndex];
      _distanceToNextTurn = nextTurn['distance'];
    }
  }

  void _provideNavigationInstructions(LatLng newPosition) {
    if (_lastPosition == null) {
      _lastPosition = Position(
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );
      return;
    }

    double distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distance > 1) {
      // Adjusted to 1 meter
      _flutterTts
          .speak("You are moving towards your destination.")
          .catchError((e) {
        _showMessage('Failed to announce movement: $e');
      });
      _lastPosition = Position(
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );
    }
  }

  void _calculateDistance() {
    _distance = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      widget.end.latitude,
      widget.end.longitude,
    ).toDouble();

    setState(() {});

    if (_distance < 1) {
      _flutterTts
          .speak("You have reached ${widget.destinationName}.")
          .catchError((e) {
        _showMessage('Failed to announce arrival: $e');
      });

      _showArrivalDialog();
    }
  }

  void _updateHeading(LatLng newPosition) {
    if (_route.isNotEmpty) {
      LatLng nextWaypoint = _route.first;
      double heading = Geolocator.bearingBetween(
        newPosition.latitude,
        newPosition.longitude,
        nextWaypoint.latitude,
        nextWaypoint.longitude,
      );
      setState(() {
        _currentHeading = heading;
      });
    }
  }

  void _speakDestinationName() {
    _flutterTts
        .speak("Navigating to ${widget.destinationName}")
        .catchError((e) {
      _showMessage('Failed to speak destination name: $e');
    });
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Arrival'),
          content: Text('You have reached ${widget.destinationName}.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _centerMapOnCurrentLocation() async {
    await _getCurrentLocation(); // Re-fetch the current location
    _mapController.move(_currentPosition, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black45,
        title: const Text(
          'Map Navigation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black45,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Distance to Destination: ${(_distance).toStringAsFixed(2)} m\n'
              'Distance to Next Turn: ${(_distanceToNextTurn).toStringAsFixed(2)} m',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: _centerMapOnCurrentLocation,
            child: const Text('Current Location'),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 90.0,
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
                if (_route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 80.0,
                      height: 80.0,
                      builder: (ctx) => Transform.rotate(
                        angle: _currentHeading * (3.1415926535897932 / 180),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ),
                    Marker(
                      point: widget.end,
                      width: 80.0,
                      height: 80.0,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
