<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "rainfall_based_system"; // make sure your database name matches

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}

// Get all barangays
$sql = "SELECT * FROM barangays";
$result = $conn->query($sql);

if (!$result) {
    die(json_encode(["error" => $conn->error]));
}

$barangays = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $barangayId = $row['id'];

        // Check if flood_forecast table exists before querying
        $tableCheck = $conn->query("SHOW TABLES LIKE 'flood_forecast'");
        $forecast = [];

        if ($tableCheck && $tableCheck->num_rows > 0) {
            $forecastSql = "SELECT * FROM flood_forecast WHERE barangay_id = $barangayId ORDER BY date ASC LIMIT 5";
            $forecastResult = $conn->query($forecastSql);

            if ($forecastResult && $forecastResult->num_rows > 0) {
                while ($f = $forecastResult->fetch_assoc()) {
                    $forecast[] = [
                        "date" => $f['date'],
                        "rainfall" => (float)$f['rainfall'],
                        "risk" => $f['risk']
                    ];
                }
            }
        }

        $barangays[] = [
            "id" => $row['id'],
            "name" => $row['name'],
            "lat" => (float)$row['lat'],
            "lon" => (float)$row['lon'],
            "forecast" => $forecast
        ];
    }
}

echo json_encode($barangays);
$conn->close();