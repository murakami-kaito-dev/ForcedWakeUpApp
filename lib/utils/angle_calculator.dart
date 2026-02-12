import 'dart:math';

double calculateAngle(Point<double> a, Point<double> b, Point<double> c) {
  final radians =
      atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
  var degrees = radians * 180 / pi;
  if (degrees < 0) degrees += 360;
  if (degrees > 180) degrees = 360 - degrees;
  return degrees;
}
