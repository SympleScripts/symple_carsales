-- ========================================
-- SYMPLE CAR SALES - DATABASE TABLES
-- ========================================

-- Table for storing vehicle information and prices
-- This table should contain all vehicle models and their market values
CREATE TABLE IF NOT EXISTS `vehicles` (
  `model` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `category` varchar(50) DEFAULT 'sedans',
  `type` varchar(50) DEFAULT 'automobile',
  PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample vehicle data (add more vehicles as needed)
INSERT INTO `vehicles` (`model`, `name`, `price`, `category`, `type`) VALUES
('adder', 'Truffade Adder', 1000000, 'super', 'automobile'),
('zentorno', 'Pegassi Zentorno', 725000, 'super', 'automobile'),
('t20', 'Progen T20', 2200000, 'super', 'automobile'),
('sultan', 'Karin Sultan', 12000, 'sports', 'automobile'),
('elegy2', 'Annis Elegy RH8', 95000, 'sports', 'automobile'),
('jester', 'Dinka Jester', 240000, 'sports', 'automobile'),
('kuruma', 'Karin Kuruma', 95000, 'sports', 'automobile'),
('blista', 'Dinka Blista', 8000, 'compacts', 'automobile'),
('panto', 'Benefactor Panto', 85000, 'compacts', 'automobile'),
('prairie', 'Bollokan Prairie', 12000, 'compacts', 'automobile'),
('asea', 'Declasse Asea', 12000, 'sedans', 'automobile'),
('asterope', 'Karin Asterope', 26000, 'sedans', 'automobile'),
('fugitive', 'Cheval Fugitive', 24000, 'sedans', 'automobile'),
('premier', 'Declasse Premier', 10000, 'sedans', 'automobile'),
('primo', 'Albany Primo', 9000, 'sedans', 'automobile'),
('regina', 'Dundreary Regina', 8000, 'sedans', 'automobile'),
('stanier', 'Vapid Stanier', 10000, 'sedans', 'automobile'),
('stratum', 'Zirconium Stratum', 10000, 'sedans', 'automobile'),
('surge', 'Cheval Surge', 38000, 'sedans', 'automobile'),
('tailgater', 'Obey Tailgater', 55000, 'sedans', 'automobile'),
('washington', 'Albany Washington', 15000, 'sedans', 'automobile'),
('baller', 'Gallivanter Baller', 90000, 'suvs', 'automobile'),
('cavalcade', 'Albany Cavalcade', 60000, 'suvs', 'automobile'),
('dubsta', 'Benefactor Dubsta', 45000, 'suvs', 'automobile'),
('fq2', 'Fathom FQ 2', 50000, 'suvs', 'automobile'),
('granger', 'Declasse Granger', 35000, 'suvs', 'automobile'),
('huntley', 'Enus Huntley S', 195000, 'suvs', 'automobile'),
('landstalker', 'Dundreary Landstalker', 58000, 'suvs', 'automobile'),
('mesa', 'Canis Mesa', 87000, 'suvs', 'automobile'),
('patriot', 'Mammoth Patriot', 50000, 'suvs', 'automobile'),
('radi', 'Vapid Radius', 32000, 'suvs', 'automobile'),
('rocoto', 'Obey Rocoto', 85000, 'suvs', 'automobile'),
('seminole', 'Canis Seminole', 30000, 'suvs', 'automobile'),
('serrano', 'Benefactor Serrano', 60000, 'suvs', 'automobile'),
('bison', 'Bravado Bison', 30000, 'vans', 'automobile'),
('bobcatxl', 'Vapid Bobcat XL', 23000, 'vans', 'automobile'),
('burrito', 'Declasse Burrito', 13000, 'vans', 'automobile'),
('burrito2', 'Declasse Gang Burrito', 13000, 'vans', 'automobile'),
('burrito3', 'Declasse Burrito', 13000, 'vans', 'automobile'),
('burrito4', 'Declasse Burrito', 13000, 'vans', 'automobile'),
('minivan', 'Vapid Minivan', 30000, 'vans', 'automobile'),
('paradise', 'Bravado Paradise', 25000, 'vans', 'automobile'),
('rumpo', 'Bravado Rumpo', 13000, 'vans', 'automobile'),
('speedo', 'Vapid Speedo', 14500, 'vans', 'automobile'),
('youga', 'Bravado Youga', 16000, 'vans', 'automobile');

-- Original occasion vehicles table (keeping for compatibility)
CREATE TABLE IF NOT EXISTS `occasion_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller` varchar(50) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `mods` text DEFAULT NULL,
  `occasionid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `occasionId` (`occasionid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
