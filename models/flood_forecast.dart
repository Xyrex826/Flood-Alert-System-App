class FloodForecast {
  final String date;
  final String day;
  final double rainfall;
  final String risk;

  FloodForecast({
    required this.date,
    required this.day,
    required this.rainfall,
    required this.risk,
  });

  factory FloodForecast.fromJson(Map<String, dynamic> json) {
    return FloodForecast(
      date: json['date'],
      day: json['day'],
      rainfall: (json['rainfall_mm'] as num).toDouble(),
      risk: json['risk'],
    );
  }
}
