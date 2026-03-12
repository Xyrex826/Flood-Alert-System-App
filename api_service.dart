import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/current_weather.dart';
import '../models/flood_risk_forecast.dart';
import '../models/barangay_with_forecast.dart';

class ApiService {
  // Using a private constant for the base URL.
  // For production apps, this should be managed via environment configuration.
  static const String _baseUrl =
      'http://192.168.254.106/Flood%20Warning%20System%20App%202/flutter_application_2/api';

  // Centralizing endpoint paths.
  static const String _forecastsUrl = "$_baseUrl/get_forecasts.php";
  static const String _allBarangayForecastsUrl =
      "$_baseUrl/fetch_all_barangay_forecast.php";

  static Future<List<Forecast>> fetchForecasts() async {
    final response = await http.get(Uri.parse(_forecastsUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Forecast.fromJson(e)).toList();
    }

    throw Exception(
      "Failed to load forecasts. Status code: ${response.statusCode}",
    );
  }

  static Future<List<BarangayWithForecast>> fetchAllBarangayForecasts() async {
    final response = await http.get(Uri.parse(_allBarangayForecastsUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((b) => BarangayWithForecast.fromJson(b)).toList();
    }

    throw Exception(
      "Failed to load barangay forecasts. Status code: ${response.statusCode}",
    );
  }
}
