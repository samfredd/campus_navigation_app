import 'package:flutter/material.dart';
import 'package:navigator/models/location_model.dart';
import 'package:navigator/pages/map_page.dart';
import 'package:navigator/services/firebase_services.dart';
import 'package:navigator/services/location_services.dart';
import 'package:provider/provider.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:latlong2/latlong.dart';
import 'ar_nav_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<LocationModel> _locations = [];
  LatLng _currentPosition = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _getCurrentLocation();
  }

  Future<void> _loadLocations() async {
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    final locations = await firebaseService.fetchLocations();
    setState(() {
      _locations = locations;
    });
  }

  Future<void> _getCurrentLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _navigateToLocation(LocationModel location) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map Navigation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapNavPage(
                      end: location.position,
                      destinationName: location.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_in_ar),
              title: const Text('AR Navigation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ARNavPage(
                      start: _currentPosition,
                      end: location.position,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        centerTitle: true,
        title: const Text(
          'OOU Navigation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black45,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_currentPosition.latitude != 0)
              // Text(
              //     'Current Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}'),
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GlassContainer(
                        height: 80,
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                        borderColor: Colors.black,
                        blur: 20,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                location.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                  style: const TextStyle(color: Colors.white),
                                  '${location.position.latitude}, ${location.position.longitude}'),
                              onTap: () => _navigateToLocation(location),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
