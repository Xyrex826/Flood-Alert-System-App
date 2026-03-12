import 'package:flutter/material.dart';
import '../models/current_weather.dart';

class FloodForecastList extends StatelessWidget {
  final List<Forecast> forecasts;

  const FloodForecastList({super.key, required this.forecasts});

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'HIGH':
      case 'DANGER':
        return Colors.red;
      case 'MEDIUM':
      case 'WARNING':
        return Colors.orange;
      case 'LOW':
        return Colors.yellow[700]!;
      case 'SAFE':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const Center(child: Text("No forecast data available."));
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final item = forecasts[index];
          final color = _getRiskColor(item.riskLevel);

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Day ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ), // Ideally use a date field if added to model
                Text(
                  item.riskLevel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(),
                Text(
                  "Rain: ${item.rain3h}mm",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "Intensity: ${item.intensity}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
