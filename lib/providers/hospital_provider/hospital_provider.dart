import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inneed/Models/hospital_model.dart';

class HospitalProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};

  // Empty list for live hospitals from API
  List<HospitalModel> _hospitals = [];

  // Google API Key
  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  //getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  Set<Marker> get markers => _markers;
  List<HospitalModel> get hospitals => _hospitals;

  //fetching user live location and permission
  Future<void> fetchUserLocation() async {
    _isLoading = true;
    notifyListeners();
    bool serviceEnabled;
    LocationPermission permission;

    //for checking mobile gps is on or off
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    //for checking permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    //get live lat/lng
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //fetching live nearby hospitals from Places API
    if (_currentPosition != null) {
      await fetchNearbyHospitalsFromApi(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }

    //creating map markers after getting location
    _createMarkers();
    _isLoading = false;
    notifyListeners();
  }

  //fetching hospitals from Google Places API
  Future<void> fetchNearbyHospitalsFromApi(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=hospital&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint("API Response Status Code: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = (data['results'] as List).take(5).toList();

        List<HospitalModel> loadedHospitals = [];

        for (var place in results) {
          double hLat = place['geometry']['location']['lat'];
          double hLng = place['geometry']['location']['lng'];

          double distanceInMeters = Geolocator.distanceBetween(lat, lng, hLat, hLng);
          double distanceInKm = double.parse((distanceInMeters / 1000).toStringAsFixed(1));

          loadedHospitals.add(
            HospitalModel(
              id: place['place_id'] ?? DateTime.now().toString(),
              name: place['name'] ?? 'Hospital',
              address: place['vicinity'] ?? 'Address not available',
              distance: distanceInKm,
              rating: (place['rating'] != null) ? (place['rating'] as num).toDouble() : 0.0,
              isAvailable: place['business_status'] == 'OPERATIONAL',
              phoneNumber: '1122',
              latitude: hLat,
              longitude: hLng,
            ),
          );
        }

        _hospitals = loadedHospitals;
      }
    } catch (e) {
      debugPrint("API Fetch Error: $e");
    }
  }

  //function 2..setting markers on map
  void _createMarkers() {
    _markers.clear();
    //blue marker on user location
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    //red markers on hospital location
    for (var hospital in _hospitals) {
      _markers.add(
        Marker(
          markerId: MarkerId(hospital.id),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(
            title: hospital.name,
            snippet: hospital.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }
}