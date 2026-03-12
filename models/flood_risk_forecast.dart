class FloodRiskForecast {
  final String date;
  final String day;
  final double rainfall;
  final String risk;

  FloodRiskForecast({
    required this.date,
    required this.day,
    required this.rainfall,
    required this.risk,
  });

  factory FloodRiskForecast.fromJson(Map<String, dynamic> json) {
    return FloodRiskForecast(
      date: json['date'],
      day: json['day'],
      rainfall: (json['rainfall_mm'] as num).toDouble(),
      risk: json['risk'],
    );
  }
}
