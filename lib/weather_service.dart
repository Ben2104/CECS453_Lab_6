import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null ||
        apiKey.trim().isEmpty ||
        apiKey == 'your_api_key_here') {
      throw Exception('Missing API key. Add API_KEY to your .env file.');
    }
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': apiKey,
      'units': 'metric',
    });
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) {
      throw Exception('City not found. Check the spelling and try again.');
    }
    throw Exception('Failed to load weather data');
  }
}
