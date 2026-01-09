<?php
header('Content-Type: application/json');

// Database connection
$host = getenv('DB_HOST') ?: 'mysql';
$dbname = getenv('DB_NAME') ?: 'microservices_db';
$user = getenv('DB_USER') ?: 'app_user';
$pass = getenv('DB_PASSWORD') ?: 'userpass';

$response = [
    'status' => 'success',
    'service' => 'PHP Microservice API',
    'timestamp' => date('Y-m-d H:i:s'),
    'endpoints' => [
        '/api/health' => 'Health check',
        '/api/users' => 'Get users',
        '/api/products' => 'Get products'
    ]
];

// Test database connection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $response['database'] = 'connected';
    
    // Create users table if not exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Insert sample data if empty
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result['count'] == 0) {
        $pdo->exec("INSERT INTO users (name, email) VALUES 
            ('John Doe', 'john@example.com'),
            ('Jane Smith', 'jane@example.com')");
    }
    
} catch (PDOException $e) {
    $response['database'] = 'error: ' . $e->getMessage();
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
