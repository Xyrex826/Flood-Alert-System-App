import 'package:flutter/material.dart';
import '../models/current_weather.dart';

class BarangayCard extends StatelessWidget {
  final Forecast forecast;

  const BarangayCard({super.key, required this.forecast});

  Color getRiskColor() {
    switch (forecast.riskLevel) {
      case "CRITICAL":
        return Colors.red;
      case "ALERT":
        return Colors.orange;
      case "MONITOR":
        return Colors.yellow.shade700;
      default:
        return Colors.green;
    }
  }

  IconData getRiskIcon() {
    switch (forecast.riskLevel) {
      case "CRITICAL":
        return Icons.warning;
      case "ALERT":
        return Icons.notification_important;
      case "MONITOR":
        return Icons.remove_red_eye;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: getRiskColor().withOpacity(0.15),
        ),

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            const Spacer(),

            Icon(getRiskIcon(), size: 42, color: getRiskColor()),

            const SizedBox(height: 8),

            Text(
              forecast.barangayId,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getRiskColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                forecast.riskLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
