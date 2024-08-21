import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

class ARViewPage extends StatefulWidget {
  const ARViewPage({super.key});

  @override
  ARViewPageState createState() => ARViewPageState();
}

class ARViewPageState extends State<ARViewPage> {
  ArCoreController? arCoreController;

  @override
  void initState() {
    super.initState();
    // No need to load the ML model anymore
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    // Optionally add initial AR objects or nodes here
  }

  void _addARObject(Vector3 position) {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        radius: 0.1,
        materials: [ArCoreMaterial()], // Customize color or materials as needed
      ),
      position: position,
    );
    arCoreController?.addArCoreNode(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example position; replace with actual logic to get position
          _addARObject(Vector3(0.0, 0.0, -1.0));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
