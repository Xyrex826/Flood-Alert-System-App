class Forecast {
  final String barangayId;
  final double rain3h;
  final double intensity;
  final int duration;
  final String geography;
  final String riskLevel;

  Forecast({
    required this.barangayId,
    required this.rain3h,
    required this.intensity,
    required this.duration,
    required this.geography,
    required this.riskLevel,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      barangayId: json['barangayId'] ?? "Unknown",
      rain3h: double.tryParse(json['rainfall']?.toString() ?? '0') ?? 0,
      intensity: 0, // if your API doesn't provide intensity, default 0
      duration: 0, // if your API doesn't provide duration, default 0
      geography: "Unknown", // if your API doesn't provide geography
      riskLevel: json['riskLevel'] ?? "SAFE",
    );
  }
}
