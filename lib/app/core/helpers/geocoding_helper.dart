import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Helper class for converting between geographic coordinates and location addresses
class GeocodingHelper {
  /// Convert geographic coordinates to address/location
  ///
  /// Parameters:
  /// - [latitude]: The latitude coordinate
  /// - [longitude]: The longitude coordinate
  ///
  /// Returns a [Placemark] object containing location details or null if failed
  static Future<Placemark?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Convert geographic coordinates to formatted address string
  ///
  /// Parameters:
  /// - [latitude]: The latitude coordinate
  /// - [longitude]: The longitude coordinate
  ///
  /// Returns a formatted address string or null if failed
  static Future<String?> getFormattedAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemark = await getAddressFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      if (placemark != null) {
        return _formatPlacemark(placemark);
      }
      return null;
    } catch (e) {
      print('Error getting formatted address: $e');
      return null;
    }
  }

  /// Convert location/address to geographic coordinates
  ///
  /// Parameters:
  /// - [address]: The address string to convert
  ///
  /// Returns a [Location] object containing coordinates or null if failed
  static Future<Location?> getCoordinatesFromAddress({
    required String address,
  }) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Get multiple possible locations for an address
  ///
  /// Parameters:
  /// - [address]: The address string to convert
  ///
  /// Returns a list of [Location] objects or empty list if failed
  static Future<List<Location>> getAllCoordinatesFromAddress({
    required String address,
  }) async {
    try {
      final locations = await locationFromAddress(address);
      // Filter out locations with null coordinates
      return locations
          .where((loc) => loc.latitude != null && loc.longitude != null)
          .toList();
    } catch (e) {
      print('Error getting all coordinates from address: $e');
      return [];
    }
  }

  /// Get current device location coordinates
  ///
  /// Returns current [Position] or null if failed
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get current device location and convert to address
  ///
  /// Returns formatted address string or null if failed
  static Future<String?> getCurrentAddress() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      return await getFormattedAddress(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting current address: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in meters
  ///
  /// Parameters:
  /// - [lat1]: Latitude of first point
  /// - [lon1]: Longitude of first point
  /// - [lat2]: Latitude of second point
  /// - [lon2]: Longitude of second point
  ///
  /// Returns distance in meters
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Format a Placemark object into a readable address string
  static String _formatPlacemark(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street?.isNotEmpty ?? false) parts.add(placemark.street!);
    if (placemark.subLocality?.isNotEmpty ?? false) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty ?? false) parts.add(placemark.locality!);
    if (placemark.administrativeArea?.isNotEmpty ?? false) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode?.isNotEmpty ?? false) {
      parts.add(placemark.postalCode!);
    }
    if (placemark.country?.isNotEmpty ?? false) parts.add(placemark.country!);

    return parts.join(', ');
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
