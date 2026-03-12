// widgets/flood_risk_card.dart
import 'package:flutter/material.dart';
import '../models/flood_risk_forecast.dart';

class FloodRiskCard extends StatelessWidget {
  final FloodRiskForecast forecast;

  const FloodRiskCard({super.key, required this.forecast});

  Color getColor() {
    switch (forecast.risk) {
      case "SAFE":
        return Colors.green;
      case "MONITOR":
        return Colors.orange;
      case "ALERT":
        return Colors.redAccent;
      case "CRITICAL":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            forecast.day, // ✅ FIXED
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("${forecast.rainfall.toStringAsFixed(1)} mm"),
          const SizedBox(height: 4),
          Text(
            forecast.risk,
            style: TextStyle(fontWeight: FontWeight.bold, color: getColor()),
          ),
        ],
      ),
    );
  }
}
