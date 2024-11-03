import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(41.40338, 2.17403);
  final Set<Marker> _markers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFetchingGPSData();
  }

  void _startFetchingGPSData() {
    _fetchGPSData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchGPSData();
    });
  }

  String? apiKey = dotenv.env['API_KEY'];

  Future<void> _fetchGPSData() async {
    String url =
        'https://api.thingspeak.com/channels/2686295/feeds.json?api_key=$apiKey&results=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = data['feeds'];

        if (feeds.isNotEmpty) {
          final latestFeed = feeds[0];
          final latitude = double.parse(latestFeed['field1']);
          final longitude = double.parse(latestFeed['field2']);
          setState(() {
            _currentLocation = LatLng(latitude, longitude);
            _markers.clear();
            _markers.add(Marker(
              markerId: const MarkerId('current_location'),
              position: _currentLocation,
              infoWindow: const InfoWindow(title: 'Current Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ));
          });
          mapController.moveCamera(CameraUpdate.newLatLng(_currentLocation));
        }
      } else {
        _showError('Failed to load GPS data');
      }
    } catch (e) {
      _showError('Error fetching GPS data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goToAPILocation() {
    mapController.moveCamera(CameraUpdate.newLatLng(_currentLocation));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        elevation: 2,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          mapController.moveCamera(CameraUpdate.newLatLng(_currentLocation));
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 13.0,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAPILocation,
        tooltip: 'Go to API Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
