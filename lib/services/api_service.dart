import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/constants.dart';

class ApiService {
  Future<LatLng?> fetchGPSData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = data['feeds'];
        if (feeds.isNotEmpty) {
          final latestFeed = feeds[0];
          final latitude = double.parse(latestFeed['field1']);
          final longitude = double.parse(latestFeed['field2']);
          return LatLng(latitude, longitude);
        }
      } else {
        print('Failed to load GPS data');
      }
    } catch (e) {
      print('Error fetching GPS data: $e');
    }
    return null;
  }
}
