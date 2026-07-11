<?php
echo "<h1>Rocky Linux LAMP Stack Running Successfully!</h1>";

// Test Database Connection
$host = '127.0.0.1';
$user = 'root';
$pass = 'secretpassword';

$conn = new mysqli($host, $user, $pass);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
} 
echo "<p style='color:green;'>✔ Successfully connected to MariaDB Database!</p>";
phpinfo();
?>
