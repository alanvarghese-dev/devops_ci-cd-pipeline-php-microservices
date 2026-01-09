<!DOCTYPE html>
<html>
<head>
    <title>PHP Microservices Dashboard</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .service { padding: 20px; margin: 10px 0; border-radius: 5px; }
        .frontend { background: #e3f2fd; }
        .api { background: #f3e5f5; }
        .database { background: #e8f5e8; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 PHP Microservices Dashboard</h1>
        
        <div class="service frontend">
            <h2>Frontend Service</h2>
            <p>Container: <?php echo gethostname(); ?></p>
            <p>PHP Version: <?php echo phpversion(); ?></p>
        </div>

        <div class="service api">
            <h2>API Service Data</h2>
            <?php
            $api_url = getenv('API_URL') ?: 'http://api';
            
            // Fetch users from API
            $users = @file_get_contents($api_url . '/users');
            $products = @file_get_contents($api_url . '/products');
            
            if ($users) {
                echo "<h3>Users</h3>";
                $users_data = json_decode($users, true);
                if (is_array($users_data)) {
                    echo "<table>";
                    echo "<tr><th>ID</th><th>Name</th><th>Email</th></tr>";
                    foreach ($users_data as $user) {
                        echo "<tr><td>{$user['id']}</td><td>{$user['name']}</td><td>{$user['email']}</td></tr>";
                    }
                    echo "</table>";
                }
            } else {
                echo "<p>Error connecting to API service</p>";
            }
            
            if ($products) {
                echo "<h3>Products</h3>";
                $products_data = json_decode($products, true);
                if (is_array($products_data)) {
                    echo "<table>";
                    echo "<tr><th>ID</th><th>Name</th><th>Price</th><th>Stock</th></tr>";
                    foreach ($products_data as $product) {
                        echo "<tr><td>{$product['id']}</td><td>{$product['name']}</td><td>\${$product['price']}</td><td>{$product['stock']}</td></tr>";
                    }
                    echo "</table>";
                }
            }
            ?>
        </div>

        <div class="service database">
            <h2>Database Connection</h2>
            <p>MySQL via API Service</p>
            <p>API URL: <?php echo $api_url; ?></p>
        </div>
    </div>
</body>
</html>
