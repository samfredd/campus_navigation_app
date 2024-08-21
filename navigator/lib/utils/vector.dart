import 'package:vector_math/vector_math_64.dart';

class CustomVector3 {
  final double x;
  final double y;
  final double z;

  CustomVector3(this.x, this.y, this.z);

  // Convert to Vector3
  Vector3 toVector3() {
    return Vector3(x, y, z);
  }
}
