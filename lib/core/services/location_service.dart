import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mineai/core/constants/app_strings.dart';

class LocationService {
  static Future<String> getCurrentCityLocation() async {
    try {
      // 1. Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // 2. If denied, explicitly request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return AppStrings.locationDenied;
        }
      }

      // 3. If permanently denied, prompt to open device settings
      if (permission == LocationPermission.deniedForever) {
        // Opens device settings so the user can toggle permission manually
        await Geolocator.openAppSettings();
        return AppStrings.locationDeniedForever;
      }

      // 4. Verify location services (GPS) are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return AppStrings.locationError;
      }

      // 5. Retrieve device coordinates
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 6. Reverse-geocode coordinates to city and country
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final city = place.locality?.isNotEmpty == true
            ? place.locality
            : (place.subAdministrativeArea ?? place.administrativeArea ?? '');
        final country = place.isoCountryCode ?? place.country ?? '';

        if (city != null && city.isNotEmpty) {
          return '$city, $country';
        }
      }

      return "AppStrings.yourLocation";
    } catch (e) {
      return '${AppStrings.account} $e';
    }
  }
}
