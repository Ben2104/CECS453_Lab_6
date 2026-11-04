import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_app/weather_service.dart';

void main() {
  setUp(() => dotenv.loadFromString(envString: 'API_KEY=test-key'));

  test('fetches metric weather for the requested city', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['q'], 'Long Beach');
      expect(request.url.queryParameters['units'], 'metric');
      expect(request.url.queryParameters['appid'], 'test-key');
      return http.Response('{"name":"Long Beach"}', 200);
    });
    expect(await WeatherService(client: client).fetchWeather('Long Beach'), {
      'name': 'Long Beach',
    });
  });

  test('throws when the API returns an error', () async {
    final client = MockClient((_) async => http.Response('', 404));
    expect(
      WeatherService(client: client).fetchWeather('unknown'),
      throwsA(isA<Exception>()),
    );
  });
}
