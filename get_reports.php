<?php

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/config.php';

/*
This API returns historical forecast reports
for the Reports page.
*/

$sql = "
SELECT 
    b.name AS barangay,
    f.rain_3h,
    f.risk_level,
    f.created_at
FROM forecasts f
JOIN barangays b ON b.id = f.barangay_id
ORDER BY f.created_at DESC
";

$result = $conn->query($sql);

$reports = [];

while ($row = $result->fetch_assoc()) {
    $reports[] = $row;
}

echo json_encode($reports);