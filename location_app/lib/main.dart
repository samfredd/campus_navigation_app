import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location_app/locations.dart';
import 'package:provider/provider.dart';
import 'map_page.dart';
import 'marker_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MarkerProvider(),
      child: MaterialApp(
        title: 'Admin App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          '/map': (context) => const MapPage(),
          '/saved_locations': (context) => const ViewLocationsPage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin App')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: const Text('Map'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/saved_locations');
            //   },
            //   child: const Text('View Locations'),
            // ),
          ],
        ),
      ),
    );
  }
}
