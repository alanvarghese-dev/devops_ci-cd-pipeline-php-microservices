<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'healthy',
    'service' => 'PHP API',
    'timestamp' => date('Y-m-d H:i:s'),
    'uptime' => exec('uptime -p')
], JSON_PRETTY_PRINT);
?>
