import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['API_KEY'] ?? '';
String apiUrl = 'https://api.thingspeak.com/channels/2686295/feeds.json?api_key=$apiKey&results=1';
