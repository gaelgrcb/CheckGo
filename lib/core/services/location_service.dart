import 'package:geolocator/geolocator.dart';
import '../../features/branches/domain/entities/branch.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  bool isWithinBranch(Position currentPos, Branch branch) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      branch.latitude,
      branch.longitude,
    );

    return distanceInMeters <= branch.toleranceRadiusMeters;
  }
}
