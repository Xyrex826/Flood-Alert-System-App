class WeatherForecast {
  final String date;
  final double temperature;
  final String description;
  final String icon;

  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List?;
    final weatherData = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList[0] as Map<String, dynamic>
        : <String, dynamic>{};

    return WeatherForecast(
      date: json['dt_txt']?.toString() ?? "Unknown",
      temperature:
          double.tryParse(json['main']?['temp']?.toString() ?? '0') ?? 0.0,
      description: weatherData['description']?.toString() ?? "Unknown",
      icon: weatherData['icon']?.toString() ?? "",
    );
  }
}
