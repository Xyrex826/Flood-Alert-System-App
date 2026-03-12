import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/current_weather.dart';
import '../services/api_service.dart';
import '../widgets/barangay_card.dart';
import '../models/weather_forecast.dart';
import '../widgets/flood_risk_card.dart';
import '../models/flood_risk_forecast.dart';
import '../models/barangay_with_forecast.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Forecast>> forecasts;

  // NEW: List of barangays with 5-day forecast
  late Future<List<BarangayWithForecast>> barangaysForecast;

  late PageController pageController;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    forecasts = ApiService.fetchForecasts();

    // FETCH ALL BARANGAYS WITH THEIR 5-DAY FORECAST
    barangaysForecast = ApiService.fetchAllBarangayForecasts();

    pageController = PageController(viewportFraction: 0.78);
  }

  Future<void> refreshData() async {
    setState(() {
      forecasts = ApiService.fetchForecasts();
      barangaysForecast = ApiService.fetchAllBarangayForecasts();
    });
  }

  int riskPriority(String risk) {
    switch (risk) {
      case "CRITICAL":
        return 0;
      case "ALERT":
        return 1;
      case "MONITOR":
        return 2;
      default:
        return 3;
    }
  }

  Map<String, int> calculateSummary(List<Forecast> data) {
    int safe = 0;
    int monitor = 0;
    int alert = 0;
    int critical = 0;

    for (var f in data) {
      switch (f.riskLevel) {
        case "SAFE":
          safe++;
          break;
        case "MONITOR":
          monitor++;
          break;
        case "ALERT":
          alert++;
          break;
        case "CRITICAL":
          critical++;
          break;
      }
    }

    return {
      "safe": safe,
      "monitor": monitor,
      "alert": alert,
      "critical": critical,
    };
  }

  void searchBarangay(List<Forecast> data, String query) {
    int index = data.indexWhere(
      (b) => b.barangayId.toLowerCase().contains(query.toLowerCase()),
    );

    if (index != -1) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget buildDots(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool active = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
        ),
      ),
    );
  }

  Widget buildSearchBar(List<Forecast> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10),
          ],
        ),
        child: TextField(
          onChanged: (value) => searchBarangay(data, value),
          decoration: const InputDecoration(
            hintText: "Search your barangay",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "CDO Flood-Watch",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Forecast>>(
        future: forecasts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text("No flood data available"));
          }

          final summary = calculateSummary(data);

          data.sort(
            (a, b) =>
                riskPriority(a.riskLevel).compareTo(riskPriority(b.riskLevel)),
          );

          return RefreshIndicator(
            onRefresh: refreshData,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                buildSectionTitle("Flood Risk Overview"),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      buildSummaryCard("Safe", summary["safe"]!, Colors.green),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Monitor",
                        summary["monitor"]!,
                        Colors.yellow.shade700,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Alert",
                        summary["alert"]!,
                        Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Critical",
                        summary["critical"]!,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                buildSectionTitle("Find Your Barangay"),
                const SizedBox(height: 12),
                buildSearchBar(data),
                const SizedBox(height: 30),
                buildSectionTitle("Current Barangay Flood Status"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: data.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: currentPage == index ? 0 : 10,
                        ),
                        child: BarangayCard(forecast: data[index]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                buildDots(data.length),
                const SizedBox(height: 30),

                // ===============================
                // 5 DAY FLOOD RISK FORECAST FOR ALL BARANGAYS
                // ===============================
                buildSectionTitle("5 Day Flood Risk Forecast"),
                const SizedBox(height: 16),
                FutureBuilder<List<BarangayWithForecast>>(
                  future: barangaysForecast,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final barangays = snapshot.data!;

                    // FIXED: Use ListView.builder with shrinkWrap
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: barangays.length,
                      itemBuilder: (context, index) {
                        final b = barangays[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                b.forecasts.isNotEmpty
                                    ? b.barangay
                                    : "${b.barangay} (No forecast)",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                children: b.forecasts
                                    .map((f) => FloodRiskCard(forecast: f))
                                    .toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
