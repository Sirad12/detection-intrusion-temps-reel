-- Table: sales
CREATE TABLE operations.sales (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES operations.client(id) ON DELETE CASCADE,
    product_id INT REFERENCES operations.product(id) ON DELETE CASCADE,
    deliverer_id INT REFERENCES operations.deliverer(id) ON DELETE CASCADE,
    bill_code VARCHAR(100),
    qte NUMERIC(10, 2),
    total NUMERIC(15, 2),
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    longitude_delivery FLOAT,
    latitude_delivery FLOAT,
    status BOOLEAN DEFAULT TRUE
);