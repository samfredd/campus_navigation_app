class Pathfinding {
  final Map<String, Map<String, double>> graph = {
    'A': {'B': 1, 'C': 4},
    'B': {'A': 1, 'C': 2, 'D': 5},
    'C': {'A': 4, 'B': 2, 'D': 1},
    'D': {'B': 5, 'C': 1},
  };

  List<String> findShortestPath(String start, String end) {
    if (!graph.containsKey(start) || !graph.containsKey(end)) {
      throw ArgumentError('Start or end node not found in the graph');
    }

    var distances = <String, double>{};
    var previous = <String, String?>{};
    var unvisited = <String>{};

    for (var node in graph.keys) {
      distances[node] = double.infinity;
      previous[node] = null;
      unvisited.add(node);
    }
    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      String? closestNode;
      for (var node in unvisited) {
        if (closestNode == null || distances[node]! < distances[closestNode]!) {
          closestNode = node;
        }
      }

      if (closestNode == end) break;

      unvisited.remove(closestNode);

      var neighbors = graph[closestNode];
      if (neighbors == null) continue; // Skip if no neighbors

      for (var neighbor in neighbors.keys) {
        double alt = distances[closestNode]! + neighbors[neighbor]!;
        if (alt < distances[neighbor]!) {
          distances[neighbor] = alt;
          previous[neighbor] = closestNode;
        }
      }
    }

    var path = <String>[];
    String? at = end;
    while (at != null) {
      path.add(at);
      at = previous[at];
    }
    path = path.reversed.toList(); // Reverse to get the correct order

    return path;
  }
}
