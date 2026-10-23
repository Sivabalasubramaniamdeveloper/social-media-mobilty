import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mineai/core/constants/app_strings.dart';

class LocationDetails {
  final String state;
  final String city;
  final String displayName;

  LocationDetails({
    required this.state,
    required this.city,
    required this.displayName,
  });
}

class LocationService {
  /// 1. Verifies GPS & native permissions, returns a formatted display string
  static Future<String> getCurrentCityLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return AppStrings.locationError;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return AppStrings.locationDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return AppStrings.locationDeniedForever;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

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

      return "AppStrings.location";
    } catch (e) {
      return '${AppStrings.locationError} $e';
    }
  }

  /// 2. Returns query parameters (state, city) formatted as URL slugs for the backend
  static Future<LocationDetails> getCurrentStateAndCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final rawCity = (place.locality?.isNotEmpty == true)
            ? place.locality!
            : (place.subAdministrativeArea ?? 'tenkasi');

        final rawState = (place.administrativeArea?.isNotEmpty == true)
            ? place.administrativeArea!
            : 'tamil-nadu';

        final citySlug = rawCity.toLowerCase().trim().replaceAll(
          RegExp(r'\s+'),
          '-',
        );
        final stateSlug = rawState.toLowerCase().trim().replaceAll(
          RegExp(r'\s+'),
          '-',
        );

        return LocationDetails(
          state: stateSlug,
          city: citySlug,
          displayName: '$rawCity, $rawState',
        );
      }
    } catch (_) {}

    return LocationDetails(
      state: 'tamil-nadu',
      city: 'tenkasi',
      displayName: 'Tenkasi, Tamil Nadu',
    );
  }
}
