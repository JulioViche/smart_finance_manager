// Core - Location Service
// Servicio para obtener la ubicación actual del dispositivo
import 'package:geolocator/geolocator.dart';

/// Resultado de la ubicación
class LocationResult {
  final double latitude;
  final double longitude;
  final bool isDefault;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  /// Ubicación por defecto (0, 0)
  static const LocationResult defaultLocation = LocationResult(
    latitude: 0,
    longitude: 0,
    isDefault: true,
  );
}

/// Servicio de ubicación
class LocationService {
  /// Obtiene la ubicación actual del dispositivo
  /// Retorna LocationResult.defaultLocation si no se puede obtener
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.defaultLocation;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.defaultLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.defaultLocation;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // En caso de error, retornar ubicación por defecto
      return LocationResult.defaultLocation;
    }
  }

  /// Verifica si los permisos de ubicación están otorgados
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
