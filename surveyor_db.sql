-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jun 22, 2025 at 11:52 PM
-- Server version: 9.1.0
-- PHP Version: 8.2.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `surveyor_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `additional_labour_detail`
--

DROP TABLE IF EXISTS `additional_labour_detail`;
CREATE TABLE IF NOT EXISTS `additional_labour_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estimate_of_repair_id` int NOT NULL,
  `painting_cost` float NOT NULL,
  `painting_materiels` float NOT NULL,
  `sundries` float NOT NULL,
  `num_of_repaire_days` int NOT NULL,
  `discount_add_labour` float NOT NULL,
  `vat` enum('0','15') NOT NULL,
  `add_labour_total` float DEFAULT NULL,
  `eor_or_surveyor` enum('eor','surveyor') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_additional_labour_detail_estimate_of_repair1_idx` (`estimate_of_repair_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
CREATE TABLE IF NOT EXISTS `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int NOT NULL,
  `attachements` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_documents_survey_information1_idx` (`survey_information_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `estimate_of_repair`
--

DROP TABLE IF EXISTS `estimate_of_repair`;
CREATE TABLE IF NOT EXISTS `estimate_of_repair` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int NOT NULL,
  `current_editor` enum('eor','surveyor') DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`id`),
  KEY `fk_estimate_of_repair_verification1_idx` (`verification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `labour_detail`
--

DROP TABLE IF EXISTS `labour_detail`;
CREATE TABLE IF NOT EXISTS `labour_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `part_detail_id` int NOT NULL,
  `eor_or_surveyor` enum('eor','surveyor') NOT NULL,
  `activity` varchar(45) NOT NULL,
  `number_of_hours` int NOT NULL,
  `hourly_const_labour` float NOT NULL,
  `discount_labour` float NOT NULL,
  `vat` enum('0','15') NOT NULL,
  `labour_total` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_labour_detail_part_detail1_idx` (`part_detail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `part_detail`
--

DROP TABLE IF EXISTS `part_detail`;
CREATE TABLE IF NOT EXISTS `part_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estimate_of_repair_id` int NOT NULL,
  `part_name` varchar(150) NOT NULL,
  `quantity` int NOT NULL,
  `supplier` varchar(255) NOT NULL,
  `quality` varchar(45) NOT NULL,
  `cost_part` float NOT NULL,
  `discount_part` float NOT NULL,
  `vat` enum('0','15') NOT NULL,
  `part_total` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_part_detail_estimate_of_repair1_idx` (`estimate_of_repair_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `picture_of_domage_car`
--

DROP TABLE IF EXISTS `picture_of_domage_car`;
CREATE TABLE IF NOT EXISTS `picture_of_domage_car` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int NOT NULL,
  `path` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_picture_of_domage_car_survey_information1_idx` (`survey_information_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(45) NOT NULL,
  `status_name` varchar(45) NOT NULL,
  `description` text,
  `update_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `status_code_UNIQUE` (`status_code`),
  UNIQUE KEY `status_name_UNIQUE` (`status_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `survey`
--

DROP TABLE IF EXISTS `survey`;
CREATE TABLE IF NOT EXISTS `survey` (
  `id` int NOT NULL AUTO_INCREMENT,
  `claim_id` int NOT NULL,
  `surveyor_id` int NOT NULL,
  `current_step` varchar(45) DEFAULT NULL,
  `status_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_survey_status1_idx` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `survey_information`
--

DROP TABLE IF EXISTS `survey_information`;
CREATE TABLE IF NOT EXISTS `survey_information` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int NOT NULL,
  `garage` varchar(45) NOT NULL,
  `garage_address` varchar(255) NOT NULL,
  `garage_contact_number` varchar(100) NOT NULL,
  `eor_value` float NOT NULL,
  `invoice_number` varchar(45) NOT NULL,
  `survey_type` varchar(45) NOT NULL,
  `date_of_survey` date NOT NULL,
  `time_of_survey` time NOT NULL,
  `pre_accident_valeur` float NOT NULL,
  `showroom_price` float NOT NULL,
  `wrech_value` float NOT NULL,
  `excess_applicable` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_survey_information_verification1_idx` (`verification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_information`
--

DROP TABLE IF EXISTS `vehicle_information`;
CREATE TABLE IF NOT EXISTS `vehicle_information` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int NOT NULL,
  `make` varchar(90) DEFAULT NULL,
  `model` varchar(90) DEFAULT NULL,
  `cc` int DEFAULT NULL,
  `fuel_type` varchar(45) DEFAULT NULL,
  `transmission` varchar(45) DEFAULT NULL,
  `engime_no` varchar(90) DEFAULT NULL,
  `chasisi_no` int DEFAULT NULL,
  `vehicle_no` varchar(45) DEFAULT NULL,
  `color` varchar(45) DEFAULT NULL,
  `odometer_reading` int DEFAULT NULL,
  `is_the_vehicle_total_loss` tinyint DEFAULT NULL,
  `condition_of_vehicle` enum('good','medium') DEFAULT NULL,
  `place_of_survey` varchar(150) DEFAULT NULL,
  `point_of_impact` text,
  PRIMARY KEY (`id`),
  KEY `fk_vehicle_information_verification1_idx` (`verification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `additional_labour_detail`
--
ALTER TABLE `additional_labour_detail`
  ADD CONSTRAINT `fk_additional_labour_detail_estimate_of_repair1` FOREIGN KEY (`estimate_of_repair_id`) REFERENCES `estimate_of_repair` (`id`);

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `fk_documents_survey_information1` FOREIGN KEY (`survey_information_id`) REFERENCES `survey_information` (`id`);

--
-- Constraints for table `estimate_of_repair`
--
ALTER TABLE `estimate_of_repair`
  ADD CONSTRAINT `fk_estimate_of_repair_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);

--
-- Constraints for table `labour_detail`
--
ALTER TABLE `labour_detail`
  ADD CONSTRAINT `fk_labour_detail_part_detail1` FOREIGN KEY (`part_detail_id`) REFERENCES `part_detail` (`id`);

--
-- Constraints for table `part_detail`
--
ALTER TABLE `part_detail`
  ADD CONSTRAINT `fk_part_detail_estimate_of_repair1` FOREIGN KEY (`estimate_of_repair_id`) REFERENCES `estimate_of_repair` (`id`);

--
-- Constraints for table `picture_of_domage_car`
--
ALTER TABLE `picture_of_domage_car`
  ADD CONSTRAINT `fk_picture_of_domage_car_survey_information1` FOREIGN KEY (`survey_information_id`) REFERENCES `survey_information` (`id`);

--
-- Constraints for table `survey`
--
ALTER TABLE `survey`
  ADD CONSTRAINT `fk_survey_status1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`);

--
-- Constraints for table `survey_information`
--
ALTER TABLE `survey_information`
  ADD CONSTRAINT `fk_survey_information_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);

--
-- Constraints for table `vehicle_information`
--
ALTER TABLE `vehicle_information`
  ADD CONSTRAINT `fk_vehicle_information_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
