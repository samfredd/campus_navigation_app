import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:navigator/services/direction_services.dart';
import 'package:navigator/utils/vector.dart';

class ARNavPage extends StatefulWidget {
  final LatLng start;
  final LatLng end;

  const ARNavPage({super.key, required this.start, required this.end});

  @override
  ARNavPageState createState() => ARNavPageState();
}

class ARNavPageState extends State<ARNavPage> {
  final DirectionsService _directionsService = DirectionsService();
  final FlutterTts _flutterTts = FlutterTts();
  ArCoreController? _arCoreController;
  List<LatLng> _route = [];
  List<Map<String, dynamic>> _instructions = [];
  LatLng _currentPosition = LatLng(0, 0);
  double _distanceToNextTurn = double.infinity;
  String _nextTurnInstruction = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initNavigation();
  }

  @override
  void dispose() {
    _arCoreController?.dispose(); // Dispose of the AR controller
    super.dispose();
  }

  Future<void> _initNavigation() async {
    // Fetch route and instructions
    _route =
        await _directionsService.getRouteCoordinates(widget.start, widget.end);
    _instructions =
        await _directionsService.getTurnInstructions(widget.start, widget.end);

    await _getCurrentLocation();
    _listenToPositionChanges();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Handle location error
    }
  }

  void _listenToPositionChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPosition;
      });
      _updateNextTurnInstruction();
      _provideVoiceInstructions();
      _updateARMarkers();
    });
  }

  void _updateNextTurnInstruction() {
    if (_instructions.isEmpty) return;

    double minDistance = double.infinity;
    String nextInstruction = '';

    for (var step in _instructions) {
      LatLng stepLocation = _route.firstWhere(
          (coord) =>
              coord.latitude == step['location'][1] &&
              coord.longitude == step['location'][0],
          orElse: () => _route.last);
      double distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        stepLocation.latitude,
        stepLocation.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nextInstruction = step['instruction'];
      }
    }
    setState(() {
      _distanceToNextTurn = minDistance;
      _nextTurnInstruction = nextInstruction;
    });
  }

  void _provideVoiceInstructions() async {
    try {
      if (_distanceToNextTurn < 50 && _nextTurnInstruction.isNotEmpty) {
        await _flutterTts.speak(_nextTurnInstruction);
        await _flutterTts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      // Handle errors if necessary
    }
  }

  void _updateARMarkers() {
    if (_arCoreController != null) {
      _arCoreController!.removeNode(nodeName: 'currentPositionMarker');
      _arCoreController!.removeNode(nodeName: 'destinationMarker');

      _arCoreController!.addArCoreNode(
        ArCoreNode(
          name: 'currentPositionMarker',
          position: CustomVector3(
            _currentPosition.latitude.toDouble(),
            0,
            _currentPosition.longitude.toDouble(),
          ).toVector3(), 
          shape: ArCoreSphere(
              radius: 0.1, materials: [ArCoreMaterial(color: Colors.blue)]),
        ),
      );

      _arCoreController!.addArCoreNode(
        ArCoreNode(
          name: 'destinationMarker',
          position: CustomVector3(
            widget.end.latitude.toDouble(),
            0,
            widget.end.longitude.toDouble(),
          ).toVector3(), 
          shape: ArCoreSphere(
              radius: 0.1, materials: [ArCoreMaterial(color: Colors.red)]),
        ),
      );
    }
  }

  void _onARViewCreated(ArCoreController controller) {
    _arCoreController = controller;
    _updateARMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'AR Navigation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onARViewCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Distance to Next Turn: ${(_distanceToNextTurn / 1000).toStringAsFixed(2)} km\nInstruction: $_nextTurnInstruction',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (_currentPosition.latitude != 0 && _currentPosition.longitude != 0)
            Positioned(
              bottom: 80,
              left: 20,
              child: SizedBox(
                width: 150,
                height: 150,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: 18.0, // Adjust this value for closer zoom
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=sk.eyJ1Ijoic2FtZnJlZHgiLCJhIjoiY2x6c2ZkZmNmMjBrbTJrcjQ3cm0wNmtiYSJ9.nD0IPjT50an-7eQF15itJA",
                      additionalOptions: const {
                        'accessToken': 'sk.eyJ1Ijoic2FtZnJlZHgiLCJhIjoiY2x6c2ZkZmNmMjBrbTJrcjQ3cm0wNmtiYSJ9.nD0IPjT50an-7eQF15itJA',
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition,
                          width: 80.0,
                          height: 80.0,
                          builder: (ctx) => const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: widget.end,
                          width: 100.0,
                          height: 200.0,
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
            ),
        ],
      ),
    );
  }
}
