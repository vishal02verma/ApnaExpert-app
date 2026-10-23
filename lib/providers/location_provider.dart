import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationProvider extends ChangeNotifier {
  String _currentAddress = 'Detecting live location...';
  String _shortLocation = 'Detecting GPS...';
  bool _isLiveLocation = false;
  bool _isLoading = false;
  String? _errorMessage;
  double? _latitude;
  double? _longitude;

  String get currentAddress => _currentAddress;
  String get shortLocation => _shortLocation;
  bool get isLiveLocation => _isLiveLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  LocationProvider() {
    // Automatically fetch live GPS location on startup
    fetchLiveLocation();
  }

  /// Request GPS and fetch live device location
  Future<void> fetchLiveLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Verify if location services are enabled on the device
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _setFallbackLocation(
            error: 'Location services are disabled. Please turn on device GPS.',
          );
          return;
        }
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackLocation(
            error: 'Location permission was denied. Please allow location access.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setFallbackLocation(
          error: 'Location permissions are permanently denied. Please enable in App Settings.',
        );
        return;
      }

      // 3. Check for last known position first to provide instant feedback
      Position? position;
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          position = lastKnown;
          _latitude = position.latitude;
          _longitude = position.longitude;
          await _reverseGeocode(position.latitude, position.longitude);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error getting last known position: $e');
      }

      // 4. Fetch fresh live position with high accuracy
      try {
        final currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
        position = currentPosition;
      } catch (e) {
        debugPrint('High accuracy GPS timed out or failed: $e');
        // If high accuracy times out and we don't have a position yet, try medium accuracy
        if (position == null) {
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 8),
              ),
            );
          } catch (e2) {
            debugPrint('Medium accuracy GPS also failed: $e2');
          }
        }
      }

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLiveLocation = true;
        _errorMessage = null;

        // Reverse geocode the actual coordinates
        await _reverseGeocode(position.latitude, position.longitude);
      } else {
        _setFallbackLocation(
          error: 'Could not acquire GPS fix. Please check your signal.',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error getting location: $e');
      _setFallbackLocation(error: 'Location error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reverse geocoding with robust multi-tiered resolution:
  /// 1. OpenStreetMap Nominatim API
  /// 2. BigDataCloud Reverse Geocode API
  /// 3. Exact Coordinate display fallback (no hardcoded fake locations)
  Future<void> _reverseGeocode(double lat, double lon) async {
    bool resolved = false;

    // 1. Primary: Nominatim OpenStreetMap
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'ApnaExpertApp/1.0 (contact@apnaexpert.in)',
              'Accept-Language': 'en',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final locality = (address['suburb'] ??
                  address['neighbourhood'] ??
                  address['residential'] ??
                  address['subdistrict'] ??
                  address['road'] ??
                  address['village'] ??
                  address['hamlet'] ??
                  address['town'] ??
                  '')
              .toString()
              .trim();

          final city = (address['city'] ??
                  address['town'] ??
                  address['municipality'] ??
                  address['city_district'] ??
                  address['county'] ??
                  address['state_district'] ??
                  address['district'] ??
                  address['state'] ??
                  '')
              .toString()
              .trim();

          final state = (address['state'] ?? '').toString().trim();

          if (locality.isNotEmpty && city.isNotEmpty) {
            _shortLocation = locality == city ? city : '$locality, $city';
          } else if (city.isNotEmpty) {
            _shortLocation = state.isNotEmpty && city != state ? '$city, $state' : city;
          } else if (locality.isNotEmpty) {
            _shortLocation = locality;
          } else {
            _shortLocation = data['name']?.toString() ?? 'Current Location';
          }

          final displayName = data['display_name']?.toString();
          if (displayName != null && displayName.isNotEmpty) {
            _currentAddress = displayName;
          } else {
            _currentAddress = _shortLocation;
          }
          _isLiveLocation = true;
          resolved = true;
          return;
        }
      }
    } catch (e) {
      debugPrint('Nominatim reverse geocode error: $e');
    }

    if (resolved) return;

    // 2. Secondary Fallback: BigDataCloud Reverse Geocode API
    try {
      final bdcUri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
      );

      final bdcResponse = await http
          .get(bdcUri)
          .timeout(const Duration(seconds: 6));

      if (bdcResponse.statusCode == 200) {
        final data = jsonDecode(bdcResponse.body) as Map<String, dynamic>;
        final locality = (data['locality'] ?? '').toString().trim();
        final city = (data['city'] ?? data['principalSubdivision'] ?? '').toString().trim();
        final state = (data['principalSubdivision'] ?? '').toString().trim();
        final country = (data['countryName'] ?? '').toString().trim();

        if (locality.isNotEmpty && city.isNotEmpty) {
          _shortLocation = locality == city ? city : '$locality, $city';
        } else if (city.isNotEmpty) {
          _shortLocation = city;
        } else if (locality.isNotEmpty) {
          _shortLocation = locality;
        } else if (state.isNotEmpty) {
          _shortLocation = state;
        } else {
          _shortLocation = 'Live Location';
        }

        final parts = <String>[];
        if (locality.isNotEmpty) parts.add(locality);
        if (city.isNotEmpty && city != locality) parts.add(city);
        if (state.isNotEmpty && state != city) parts.add(state);
        if (country.isNotEmpty) parts.add(country);

        _currentAddress = parts.isNotEmpty ? parts.join(', ') : _shortLocation;
        _isLiveLocation = true;
        resolved = true;
        return;
      }
    } catch (e) {
      debugPrint('BigDataCloud reverse geocode error: $e');
    }

    if (resolved) return;

    // 3. Fallback: Display exact coordinates cleanly
    _shortLocation = 'GPS (${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°)';
    _currentAddress = 'Live Location (${lat.toStringAsFixed(4)}° N, ${lon.toStringAsFixed(4)}° E)';
    _isLiveLocation = true;
  }

  void _setFallbackLocation({
    String? error,
    String fallbackAddress = 'Sector 18, Noida, Uttar Pradesh, 201301',
    String fallbackShort = 'Sector 18, Noida',
  }) {
    _shortLocation = fallbackShort;
    _currentAddress = fallbackAddress;
    _isLiveLocation = false; // NOT a live GPS location
    _errorMessage = error;
    _latitude = 28.5708;
    _longitude = 77.3271;
  }

  /// Manually update the service location
  void setManualLocation(
    String fullAddress, {
    String? shortLabel,
    double? lat,
    double? lon,
  }) {
    _currentAddress = fullAddress;
    if (shortLabel != null && shortLabel.isNotEmpty) {
      _shortLocation = shortLabel;
    } else {
      final parts = fullAddress.split(',');
      if (parts.length >= 2) {
        _shortLocation = '${parts[0].trim()}, ${parts[1].trim()}';
      } else {
        _shortLocation = parts[0].trim();
      }
    }
    if (lat != null && lon != null) {
      _latitude = lat;
      _longitude = lon;
    }
    _isLiveLocation = false;
    _errorMessage = null;
    notifyListeners();
  }
}
