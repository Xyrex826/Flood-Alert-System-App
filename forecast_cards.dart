import 'package:flutter/material.dart';
import '../models/weather_forecast.dart';

class ForecastCard extends StatelessWidget {
  final WeatherForecast forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final iconUrl = "https://openweathermap.org/img/wn/${forecast.icon}@2x.png";

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(iconUrl, width: 50),

          const SizedBox(height: 8),

          Text(
            "${forecast.temperature.toStringAsFixed(1)}°C",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 6),

          Text(
            forecast.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
