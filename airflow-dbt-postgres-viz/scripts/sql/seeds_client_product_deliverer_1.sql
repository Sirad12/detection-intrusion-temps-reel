INSERT INTO operations.client (name, code, address, gender, status) VALUES
('Markus Tamm', 'CLT-EE-01', 'Pikk 12, Tallinn, 10123', 'M', true),
('Eliise Kask', 'CLT-EE-02', 'Riia 4, Tartu, 51004', 'F', true),
('Kristjan Mägi', 'CLT-EE-03', 'Ranna puiestee 1, Pärnu, 80010', 'M', true),
('Laura Saar', 'CLT-EE-04', 'Viru väljak 4, Tallinn, 10111', 'F', true),
('Andres Lepik', 'CLT-EE-05', 'Narva maantee 7, Tallinn, 10117', 'M', false),
('Katriin Luik', 'CLT-EE-06', 'Kesk 2, Narva, 20308', 'F', true),
('Martin Rebane', 'CLT-EE-07', 'Vabaduse puiestee 1, Viljandi, 71020', 'M', true),
('Hanna Jõgi', 'CLT-EE-08', 'Toompuiestee 35, Tallinn, 10133', 'F', true),
('Sander Mets', 'CLT-EE-09', 'Soola 8, Tartu, 51013', 'M', true),
('Grete Kangur', 'CLT-EE-10', 'Lossi 1, Kuressaare, 93816', 'F', true);

INSERT INTO operations.product (name, code, pu_price, status) VALUES
('Estonian Smart ID Card Reader', 'PRD-EST-01', 15.00, true),
('Skype-style HD Webcam', 'PRD-EST-02', 85.50, true),
('Tallinn Old Town Art Print', 'PRD-EST-03', 45.00, true),
('Organic Juniper Wood Board', 'PRD-EST-04', 35.00, true),
('E-Residency Toolkit', 'PRD-EST-05', 120.00, true),
('Woolen Mittens (Muhu design)', 'PRD-EST-06', 40.25, true),
('Vana Tallinn Liqueur Glass', 'PRD-EST-07', 12.00, true),
('Bolt-compatible Scooter Helmet', 'PRD-EST-08', 55.90, false),
('Nordic Design Coffee Mug', 'PRD-EST-09', 18.00, true),
('Estonian Flag Desk Set', 'PRD-EST-10', 10.50, true);

INSERT INTO operations.deliverer (name, code, address, gender, status) VALUES
('Siim Sepp', 'DLV-EE-01', 'Mustamäe tee 16, Tallinn', 'M', true),
('Liis Vaher', 'DLV-EE-02', 'Tähe 14, Tartu', 'F', true),
('Peeter Kuusk', 'DLV-EE-03', 'Haapsalu mnt 5, Keila', 'M', true),
('Anu Pärn', 'DLV-EE-04', 'Laki 12, Tallinn', 'F', true),
('Jüri Ratas', 'DLV-EE-05', 'Pirita tee 20, Tallinn', 'M', true),
('Tanel Padar', 'DLV-EE-06', 'Koidu 5, Tallinn', 'M', false),
('Ene Ergma', 'DLV-EE-07', 'Ülikooli 18, Tartu', 'F', true),
('Rasmus Mägi', 'DLV-EE-08', 'Kadriorg, Tallinn', 'M', true),
('Kaia Kanepi', 'DLV-EE-09', 'Aia 3, Haapsalu', 'F', true),
('Ott Tänak', 'DLV-EE-10', 'Saaremaa Way 1, Kuressaare', 'M', true);


INSERT INTO operations.sales (client_id, product_id, deliverer_id, bill_code, qte, total, create_at, longitude_delivery, latitude_delivery, status) VALUES
-- Janvier 2026
(1, 1, 3, 'BILL-12-01', 1, 1200.00, '2026-01-10 09:15:00', 24.7535, 59.4370, true),
(2, 3, 5, 'BILL-12-02', 4, 103.96, '2026-01-15 14:30:00', 26.7225, 58.3801, true),
(3, 5, 1, 'BILL-12-03', 2, 300.00, '2026-01-22 11:00:00', 24.4971, 58.3735, true),
(4, 10, 8, 'BILL-12-04', 10, 125.00, '2026-01-28 16:45:00', 28.1903, 59.3792, true),
(5, 2, 2, 'BILL-12-05', 1, 350.50, '2026-01-30 10:20:00', 22.4846, 58.2481, true),
(2, 1, 4, 'BILL-13-01', 1, 1200.00, '2026-01-05 10:00:00', 26.7225, 58.3801, true),
(5, 5, 2, 'BILL-13-02', 3, 450.00, '2026-01-12 11:30:00', 22.4846, 58.2481, true),
(8, 10, 9, 'BILL-13-03', 4, 50.00, '2026-01-18 15:45:00', 28.1903, 59.3792, true),
(1, 3, 1, 'BILL-13-04', 2, 51.98, '2026-01-25 09:20:00', 24.7535, 59.4370, true),
(10, 7, 6, 'BILL-13-05', 2, 90.00, '2026-01-29 14:10:00', 22.4846, 58.2481, true),

-- Février 2026
(6, 4, 7, 'BILL-12-06', 2, 178.00, '2026-02-05 08:30:00', 24.7441, 59.4389, true),
(7, 7, 10, 'BILL-12-07', 3, 135.00, '2026-02-12 13:15:00', 26.7112, 58.3795, true),
(8, 6, 4, 'BILL-12-08', 1, 75.25, '2026-02-18 09:05:00', 24.5012, 58.3712, true),
(9, 9, 6, 'BILL-12-09', 5, 90.00, '2026-02-24 12:40:00', 28.1850, 59.3780, true),
(10, 8, 9, 'BILL-12-10', 2, 71.80, '2026-02-27 15:55:00', 24.7391, 59.4444, false),

-- Avril 2026
(2, 6, 3, 'BILL-12-16', 2, 150.50, '2026-04-01 14:50:00', 24.7535, 59.4370, true),
(4, 3, 9, 'BILL-12-17', 5, 129.95, '2026-04-05 11:15:00', 26.7225, 58.3801, true),
(6, 7, 1, 'BILL-12-18', 4, 180.00, '2026-04-08 13:05:00', 24.4971, 58.3735, true),
(8, 9, 5, 'BILL-12-19', 10, 180.00, '2026-04-12 10:40:00', 28.1903, 59.3792, true),
(10, 8, 10, 'BILL-12-20', 1, 35.90, '2026-04-14 17:00:00', 24.7552, 59.4370, true);
