import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class DirectionViewModel extends ChangeNotifier {
  LatLng? _origin; // user current or chosen start
  LatLng? _destination; // customer's pickup address
  String? _addressLabel;
  bool _isLoading = false;
  String? _errorMessage;
  final Set<Polyline> _polylines = {};
  final String _googleApiKey = 'AIzaSyDPv-8Je2WEVCCNSr0FkSDYeSNg6jMu8n0';
  String? _pendingAddress; // Store address for retry

  final Completer<GoogleMapController> mapController = Completer();

  LatLng? get origin => _origin;
  LatLng? get destination => _destination;
  String? get addressLabel => _addressLabel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<Polyline> get polylines => _polylines;

  Future<void> initWithAddress(String address) async {
    _pendingAddress = address;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    // Try REST API first since it's more reliable
    await _fallbackGeocode(address);
    // Only try package geocoding if REST fails and no network error
    if (_destination == null && !(_errorMessage?.contains('internet') ?? false)) {
      try {
        final locations = await geocoding.locationFromAddress(address);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          _destination = LatLng(loc.latitude, loc.longitude);
          _addressLabel = address;
          _errorMessage = null;
        }
      } catch (e) {
        // Ignore package errors, use REST API error message
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> retryGeocode() async {
    if (_pendingAddress != null) {
      await initWithAddress(_pendingAddress!);
    }
  }

  Future<void> _fallbackGeocode(String address) async {
    try {
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=' + Uri.encodeComponent(address) + '&key=' + _googleApiKey);
      final res = await http.get(uri).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          _destination = LatLng(lat, lng);
          _addressLabel = address;
          _errorMessage = null;
          return;
        } else {
          _errorMessage = 'Destination not found: ${data['status']}';
        }
      } else {
        _errorMessage = 'Geocoding service error: ${res.statusCode}';
      }
    } catch (e) {
      _errorMessage = e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')
          ? 'No internet connection. Please check network and try again.'
          : 'Failed to geocode: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}';
    }
  }

  Future<void> useCurrentLocationAsStart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied. Please enable in settings.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _origin = LatLng(pos.latitude, pos.longitude);

      // Move camera to show both origin and destination
      if (mapController.isCompleted && _destination != null) {
        final controller = await mapController.future;
        final bounds = LatLngBounds(
          southwest: LatLng(
            _origin!.latitude < _destination!.latitude ? _origin!.latitude : _destination!.latitude,
            _origin!.longitude < _destination!.longitude ? _origin!.longitude : _destination!.longitude,
          ),
          northeast: LatLng(
            _origin!.latitude > _destination!.latitude ? _origin!.latitude : _destination!.latitude,
            _origin!.longitude > _destination!.longitude ? _origin!.longitude : _destination!.longitude,
          ),
        );
        await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      }
      await _buildRouteIfPossible();
    } catch (e) {
      _errorMessage = 'Unable to get current location: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startNavigation() async {
    if (_origin == null || _destination == null) return;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${_origin!.latitude},${_origin!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _errorMessage = 'Could not launch navigation';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Set<Marker> get markers {
    final set = <Marker>{};
    if (_origin != null) {
      set.add(Marker(markerId: MarkerId('origin'), position: _origin!, infoWindow: InfoWindow(title: 'Start')));
    }
    if (_destination != null) {
      set.add(Marker(markerId: MarkerId('dest'), position: _destination!, infoWindow: InfoWindow(title: 'Destination')));
    }
    return set;
  }

  CameraPosition get initialCameraPosition {
    if (_destination != null) {
      return CameraPosition(target: _destination!, zoom: 14);
    }
    // Default to a neutral camera (Kochi coordinates as placeholder)
    return const CameraPosition(target: LatLng(9.9312, 76.2673), zoom: 12);
  }

  Future<void> _buildRouteIfPossible() async {
    if (_origin == null || _destination == null) return;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_origin!.latitude},${_origin!.longitude}&'
        'destination=${_destination!.latitude},${_destination!.longitude}&'
        'key=$_googleApiKey',
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final points = route['overview_polyline']['points'];
          
          // Decode polyline points
          final polylineCoordinates = _decodePolyline(points);
          
          if (polylineCoordinates.isNotEmpty) {
            _polylines
              ..clear()
              ..add(Polyline(
                polylineId: PolylineId('route'),
                width: 6,
                color: Colors.blue,
                points: polylineCoordinates,
              ));
            notifyListeners();
          }
        } else {
          _errorMessage = data['status'] ?? 'Route not found';
          notifyListeners();
        }
      } else {
        _errorMessage = 'Failed to fetch route';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().contains('SocketException')
          ? 'No internet connection. Please check network and try again.'
          : 'Failed to draw route: $e';
      notifyListeners();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }
}


