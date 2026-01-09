-- Create additional tables if needed
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, description, price) VALUES
('Microservice Architecture Book', 'Learn microservices with PHP', 49.99),
('Docker Container Guide', 'Complete Docker guide for developers', 29.99),
('API Design Patterns', 'Best practices for API design', 39.99);
