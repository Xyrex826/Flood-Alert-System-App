<?php

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/config.php';


$API_KEY = $_ENV['API_KEY'] ?? getenv('API_KEY');

if (!$API_KEY) {
    die("Error: API_KEY not found. Check if .env exists in the root folder.");
}

$barangays = $conn->query("SELECT * FROM barangays");

$weatherUpdates = [];
while ($row = $barangays->fetch_assoc()) {

    $lat = $row['lat'];
    $lon = $row['lon'];

    $url = $url = "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$API_KEY&units=metric";
    
    $response = @file_get_contents($url);
    $data = $response ? json_decode($response, true) : null;

   
    $totalRain24h = 0.0;
    $rainyPeriods = 0;
    $maxIntensity = 0.0;
    $dailyForecasts = [];

    if (isset($data['list']) && is_array($data['list'])) {
        // 1. Calculate Summary for Next 24h (Existing Logic)
        $count = min(8, count($data['list']));
        for ($i = 0; $i < $count; $i++) {
            $entry = $data['list'][$i];
            $r3 = 0.0;
            if (isset($entry['rain']) && isset($entry['rain']['3h'])) {
                $r3 = (float)$entry['rain']['3h'];
            }
            $totalRain24h += $r3;
            if ($r3 > 0) {
                $rainyPeriods += 1;
                $intensity = $r3 / 3.0; // mm per hour
                if ($intensity > $maxIntensity) $maxIntensity = $intensity;
            }
        }

        // 2. Calculate 5-Day Forecast (New Logic)
        // OWM returns 40 items (5 days * 8 intervals of 3h)
        for ($d = 0; $d < 5; $d++) {
            $dRain = 0.0;
            $dPeriods = 0;
            $dMaxInt = 0.0;

            // Process 8 chunks (24 hours) for this day
            for ($k = 0; $k < 8; $k++) {
                $idx = ($d * 8) + $k;
                if (!isset($data['list'][$idx])) break;
                
                $entry = $data['list'][$idx];
                $r3 = 0.0;
                if (isset($entry['rain']) && isset($entry['rain']['3h'])) {
                    $r3 = (float)$entry['rain']['3h'];
                }
                
                $dRain += $r3;
                if ($r3 > 0) {
                    $dPeriods++;
                    $dInt = $r3 / 3.0;
                    if ($dInt > $dMaxInt) $dMaxInt = $dInt;
                }
            }

            // Reuse logic for scoring could be refactored, but applying simplified logic here for the list
            // Assuming geographic factors apply the same way.
            // Note: $geographicFactor is calculated below, we will use it here assuming it doesn't change per day.
            // We need to move geographicFactor calculation up or access it. 
            // For simplicity in this patch, we calculate raw values here and append later or move this block down.
            // Let's store the raw stats and process risk after geographicFactor is defined.
            
            $dailyForecasts[] = [
                'day_index' => $d + 1,
                'rain_24h' => $dRain,
                'max_intensity' => $dMaxInt,
                'periods' => $dPeriods
            ];
        }
    }

   
    
    $name = $row['name'] ?? '';
    $elevation = $row['elev'] ?? 50;
    $lowLandFlag = $row['lowLand'] ?? false; 
    
    
    $geographicFactor = ($lowLandFlag || $elevation < 10) ? 1.6 : 1.0;
    
   
    $upstreamExtra = in_array($name, ['Iponan', 'Carmen'], true) ? 12.0 : 0.0;
    

    $riskScore = 0;
    
    
   
    $adjustedRain = ($totalRain24h + $upstreamExtra) * $geographicFactor;
    $rainfallScore = min(40, ($adjustedRain / 50) * 40); // 50mm = max score 40
    $riskScore += $rainfallScore;
    
  
    $intensityScore = min(35, ($maxIntensity / 15) * 35);
    $riskScore += $intensityScore;
    

    $durationScore = min(15, ($rainyPeriods / 8) * 15);
    $riskScore += $durationScore;
    
    $geoBonus = $geographicFactor > 1.0 ? 10 : 0;
    $riskScore += $geoBonus;
    
    // Process the 5-day risk using the same geographic factors
    $finalForecastList = [];
    foreach ($dailyForecasts as $dayData) {
        $dRiskScore = 0;
        
        $dAdjRain = ($dayData['rain_24h'] + $upstreamExtra) * $geographicFactor;
        $dRainScore = min(40, ($dAdjRain / 50) * 40);
        $dRiskScore += $dRainScore;

        $dIntScore = min(35, ($dayData['max_intensity'] / 15) * 35);
        $dRiskScore += $dIntScore;

        $dDurScore = min(15, ($dayData['periods'] / 8) * 15);
        $dRiskScore += $dDurScore;

        $dRiskScore += $geoBonus;

        $dRiskLabel = 'SAFE';
        if ($dRiskScore >= 80) $dRiskLabel = 'CRITICAL';
        elseif ($dRiskScore >= 55) $dRiskLabel = 'ALERT';
        elseif ($dRiskScore >= 30) $dRiskLabel = 'MONITOR';

        $finalForecastList[] = [
            'riskLevel' => $dRiskLabel,
            'rain3h'    => $dayData['rain_24h'], // Using the model's property name 'rain3h' for the daily total
            'intensity' => $dayData['max_intensity']
        ];
    }
 
    $risk = 'SAFE';
    if ($riskScore >= 80) {
        $risk = 'CRITICAL';          
    } elseif ($riskScore >= 55) {
        $risk = 'ALERT';      
    } elseif ($riskScore >= 30) {
        $risk = 'MONITOR';       
    }
   
    $weatherUpdates[] = [
        'barangay_id' => $row['id'],
        'rain_3h'     => $totalRain24h,
        'intensity'   => $maxIntensity,
        'duration'    => $rainyPeriods,
        'geography'   => ($lowLandFlag || $elevation < 10) ? 'LOWLAND' : 'HIGHLAND',
        'geo_factor'  => $geographicFactor,
        'risk_level'  => $risk,
        'forecasts'   => $finalForecastList
    ];

   
    $check = $conn->prepare(
        "SELECT rain_3h, intensity, risk_level
         FROM forecasts
         WHERE barangay_id = ?
         ORDER BY created_at DESC
         LIMIT 1"
    );
    if ($check) {
        $check->bind_param("s", $row['id']);
        $check->execute();
        $check->bind_result($prevRain, $prevInt, $prevRisk);
        $needsInsert = true;
        if ($check->fetch()) {
          
            if (abs($prevRain - $totalRain24h) < 0.0001 &&
                abs($prevInt - $maxIntensity) < 0.0001 &&
                $prevRisk === $risk) {
                $needsInsert = false;
            }
        }
        $check->close();
    } else {
        $needsInsert = true; 
    }
if (!empty($needsInsert)) {
       
        $stmt = $conn->prepare("INSERT INTO forecasts (barangay_id, rain_3h, intensity, risk_level, rain_duration) VALUES (?, ?, ?, ?, ?)");
        
        if ($stmt) {
          
            $stmt->bind_param("sddsi", $row['id'], $totalRain24h, $maxIntensity, $risk, $rainyPeriods);
            $stmt->execute();
            $stmt->close(); // Always close the statement inside a loop
        }
    }
} 


echo json_encode($weatherUpdates);
?>