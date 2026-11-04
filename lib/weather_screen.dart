import 'package:flutter/material.dart';

import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _city = TextEditingController();
  final _service = WeatherService();
  Map<String, dynamic>? _weather;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final city = _city.text.trim();
    if (city.isEmpty) {
      setState(() {
        _error = 'Enter a city name.';
        _weather = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
    });
    try {
      final weather = await _service.fetchWeather(city);
      if (mounted) setState(() => _weather = weather);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().startsWith('Exception: ')
              ? error.toString().substring(11)
              : 'Network error. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather;
    final condition = weather == null ? null : weather['weather'][0];
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _city,
                  decoration: const InputDecoration(
                    labelText: 'City name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    if (!_loading) _search();
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _search,
                  child: const Text('Get weather'),
                ),
                const SizedBox(height: 24),
                if (_loading) const CircularProgressIndicator(),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (weather != null) ...[
                  Text(
                    weather['name'].toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Image.network(
                    'https://openweathermap.org/img/wn/${condition['icon']}@2x.png',
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.cloud, size: 80),
                  ),
                  Text(
                    '${weather['main']['temp']} °C',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(condition['description'].toString()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
