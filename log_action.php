<?php

require_once __DIR__ . '/config.php';

function createLog($user, $action, $status, $details){

    global $conn;

    $stmt = $conn->prepare("
        INSERT INTO logs (user, action, status, details)
        VALUES (?, ?, ?, ?)
    ");

    $stmt->bind_param("ssss", $user, $action, $status, $details);
    $stmt->execute();
}