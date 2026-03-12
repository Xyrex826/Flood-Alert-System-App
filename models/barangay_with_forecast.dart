import 'flood_risk_forecast.dart';

class BarangayWithForecast {
  final String barangay;
  final List<FloodRiskForecast> forecasts;

  BarangayWithForecast({required this.barangay, required this.forecasts});

  factory BarangayWithForecast.fromJson(Map<String, dynamic> json) {
    var forecastList = json['forecasts'] as List;

    List<FloodRiskForecast> forecastObjects = forecastList
        .map((f) => FloodRiskForecast.fromJson(f))
        .toList();

    return BarangayWithForecast(
      barangay: json['barangay'],
      forecasts: forecastObjects,
    );
  }
}
