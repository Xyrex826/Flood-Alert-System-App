<?php
// 1. Force error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");

// 2. Load database
ob_start();
require_once __DIR__ . "/config.php";
require_once __DIR__ . "/log_action.php"; // <-- add logging
ob_end_clean(); 

if(!isset($conn)){
    echo json_encode(["success"=>false,"message"=>"Database connection missing"]);
    exit;
}

if(!isset($_GET['id']) || empty($_GET['id'])){
    echo json_encode(["success"=>false,"message"=>"Barangay ID not provided"]);
    exit;
}

$id = trim($_GET['id']);

// 3. Prepare delete statement
$stmt = $conn->prepare("DELETE FROM barangays WHERE id = ?");
if(!$stmt){
    echo json_encode(["success"=>false,"message"=>"Prepare failed: ".$conn->error]);
    exit;
}

// Using string because your ID is text
$stmt->bind_param("s", $id);

if($stmt->execute()){

    // LOG SUCCESS
    createLog(
        "Admin",
        "Deleted Barangay",
        "Success",
        "Barangay $id deleted"
    );

    echo json_encode(["success"=>true]);

} else {

    // LOG FAILURE
    createLog(
        "Admin",
        "Deleted Barangay",
        "Failed",
        "Failed to delete barangay $id"
    );

    echo json_encode(["success"=>false,"error"=>$stmt->error]);
}

$stmt->close();
$conn->close();
?>