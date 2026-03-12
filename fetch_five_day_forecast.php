<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json; charset=utf-8");

require_once __DIR__ . '/config.php';

$lat = $_GET['lat'] ?? null;
$lon = $_GET['lon'] ?? null;

if (!$lat || !$lon) {
    echo json_encode(["error" => "lat and lon required"]);
    exit;
}

$API_KEY = $_ENV['API_KEY'];

$url = "https://api.openweathermap.org/data/2.5/forecast?lat={$lat}&lon={$lon}&appid={$API_KEY}&units=metric";

$response = file_get_contents($url);

if ($response === false) {
    echo json_encode(["error" => "Failed to fetch weather data"]);
    exit;
}

$data = json_decode($response, true);

if (!isset($data['list'])) {
    echo json_encode(["error" => "Invalid API response"]);
    exit;
}

$rainfall_per_day = [];

foreach ($data['list'] as $item) {

    $date = substr($item['dt_txt'], 0, 10);

    $rain = 0;

    if (isset($item['rain']['3h'])) {
        $rain = $item['rain']['3h'];
    }

    if (!isset($rainfall_per_day[$date])) {
        $rainfall_per_day[$date] = 0;
    }

    $rainfall_per_day[$date] += $rain;
}

$result = [];

foreach ($rainfall_per_day as $date => $rainfall) {

    // FLOOD RISK CLASSIFICATION
    if ($rainfall >= 70) {
        $risk = "CRITICAL";
    }
    elseif ($rainfall >= 40) {
        $risk = "ALERT";
    }
    elseif ($rainfall >= 20) {
        $risk = "MONITOR";
    }
    else {
        $risk = "SAFE";
    }

    $result[] = [
        "date" => $date,
        "rainfall" => round($rainfall, 2),
        "risk" => $risk
    ];
}

echo json_encode(array_slice($result, 0, 5));