import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'marker_provider.dart';

class ViewLocationsPage extends StatelessWidget {
  const ViewLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
      ),
      body: Consumer<MarkerProvider>(
        builder: (context, markerProvider, child) {
          return ListView.builder(
            itemCount: markerProvider.markers.length,
            itemBuilder: (context, index) {
              final marker = markerProvider.markers[index];

              return Dismissible(
                key: Key(marker.name), // Unique key for each item
                direction: DismissDirection.endToStart, // Swipe direction
                onDismissed: (direction) async {
                  await markerProvider.deleteMarker(marker); // Remove the marker
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${marker.name} deleted'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  title: Text(marker.name),
                  subtitle: Text('Lat: ${marker.position.latitude}, Lng: ${marker.position.longitude}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
