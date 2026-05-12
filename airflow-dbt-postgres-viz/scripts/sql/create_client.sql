-- Table: client
CREATE TABLE operations.client (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE,
    address TEXT,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    status BOOLEAN DEFAULT TRUE
);