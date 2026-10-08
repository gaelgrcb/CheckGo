class Branch {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double toleranceRadiusMeters;

  Branch({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.toleranceRadiusMeters,
  });
}
