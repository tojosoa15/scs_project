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
-- Database: `claim_user_db`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `GetListByUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetListByUser` (IN `p_email` VARCHAR(255), IN `p_status` VARCHAR(255), IN `p_search_name` VARCHAR(255), IN `p_sort_by` VARCHAR(50), IN `p_page` INT, IN `p_page_size` INT, IN `p_search_num` VARCHAR(255), IN `p_search_reg_num` VARCHAR(255), IN `p_search_phone` VARCHAR(255))   BEGIN
    DECLARE v_where TEXT;
    DECLARE v_order_by TEXT;
    DECLARE v_offset INT;
    DECLARE v_sql TEXT;
    
    -- Définir les valeurs par défaut
    SET p_email = IFNULL(p_email, '');
    SET p_status = IFNULL(p_status, '');
    SET p_search_name = IFNULL(p_search_name, '');
    SET p_sort_by = IFNULL(p_sort_by, 'date');
    SET p_page = IFNULL(p_page, 1);
    SET p_page_size = IFNULL(p_page_size, 10);
    SET p_search_num = IFNULL(p_search_num, '');
    SET p_search_reg_num = IFNULL(p_search_reg_num, '');
    SET p_search_phone = IFNULL(p_search_phone, '');

    -- Vérification de l'email
    IF p_email = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Email est un paramètre obligatoire';
    END IF;

    -- Vérification que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM account_informations WHERE email_address = p_email) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Aucun utilisateur trouvé avec cet email';
    END IF;

    SET v_where = ' WHERE 1=1 ';
    SET v_order_by = '';
    SET v_offset = (p_page - 1) * p_page_size;

    -- Application des filtres dynamiques
    IF p_status != '' THEN
        SET v_where = CONCAT(v_where, ' AND A.status = "', p_status, '" ');
    END IF;
    
    IF p_search_name != '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.name LIKE "%', p_search_name, '%" ');
    END IF;
    
    IF p_search_num != '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.number LIKE "%', p_search_num, '%" ');
    END IF;
    
    IF p_search_reg_num != '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.registration_number LIKE "%', p_search_reg_num, '%" ');
    END IF;
    
    IF p_search_phone != '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.phone LIKE "%', p_search_phone, '%" ');
    END IF;

    -- Filtrer par utilisateur (email)
    SET v_where = CONCAT(v_where, ' AND ACI.email_address = "', p_email, '" ');

    -- Tri
    CASE 
        WHEN p_sort_by = 'status' THEN SET v_order_by = ' ORDER BY A.status ASC ';
        WHEN p_sort_by = 'received_date' THEN SET v_order_by = ' ORDER BY CL.received_date DESC ';
        ELSE SET v_order_by = ' ORDER BY CL.ageing DESC ';
    END CASE;

    -- Construction de la requête
    SET v_sql = CONCAT('
        SELECT 
            CL.id AS claim_id,
            CL.received_date,
            CL.number,
            CL.name,
            CL.registration_number,
            CL.ageing,
            CL.phone,
            A.status AS status_name
        FROM claims CL
        INNER JOIN assignment A ON CL.id = A.claims_id
        INNER JOIN users US ON US.id = A.users_id
        INNER JOIN account_informations ACI ON ACI.users_id = US.id
        ', v_where, v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);

    -- Exécution de la requête
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `account_informations`
--

DROP TABLE IF EXISTS `account_informations`;
CREATE TABLE IF NOT EXISTS `account_informations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `business_name` varchar(150) NOT NULL,
  `business_registration_number` varchar(150) NOT NULL,
  `business_address` varchar(250) NOT NULL,
  `city` varchar(45) NOT NULL,
  `postal_code` varchar(45) NOT NULL,
  `phone_number` varchar(100) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `password` varchar(250) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_address_UNIQUE` (`email_address`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `account_informations`
--

INSERT INTO `account_informations` (`id`, `users_id`, `business_name`, `business_registration_number`, `business_address`, `city`, `postal_code`, `phone_number`, `email_address`, `password`, `website`) VALUES
(1, 1, 'Raharison', '1234', 'Squard Orchard', 'Quatre bornes', '7200', '55662277', 'raharisontj@gmail.com', '123456', 'www.tjweb.com');

-- --------------------------------------------------------

--
-- Table structure for table `administrative_settings`
--

DROP TABLE IF EXISTS `administrative_settings`;
CREATE TABLE IF NOT EXISTS `administrative_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `primary_contact_name` varchar(255) NOT NULL,
  `primary_contact_post` varchar(150) NOT NULL,
  `notification` text NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`),
  KEY `fk_administrative_settings_users1_idx` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `admin_settings_communications`
--

DROP TABLE IF EXISTS `admin_settings_communications`;
CREATE TABLE IF NOT EXISTS `admin_settings_communications` (
  `admin_setting_id` int NOT NULL,
  `method_id` int NOT NULL,
  `is_active` tinyint DEFAULT '1',
  PRIMARY KEY (`admin_setting_id`,`method_id`),
  KEY `fk_admin_settings_communication_communication_methods1_idx` (`method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `assignment`
--

DROP TABLE IF EXISTS `assignment`;
CREATE TABLE IF NOT EXISTS `assignment` (
  `claims_id` int NOT NULL,
  `users_id` int NOT NULL,
  `role_user` varchar(45) DEFAULT NULL,
  `assignment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `assignement_note` text,
  `status_id` int NOT NULL,
  PRIMARY KEY (`claims_id`),
  KEY `fk_assignment_claims1_idx` (`claims_id`),
  KEY `fk_assignment_users1` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
CREATE TABLE IF NOT EXISTS `claims` (
  `id` int NOT NULL AUTO_INCREMENT,
  `received_date` date NOT NULL DEFAULT (curdate()),
  `number` varchar(255) NOT NULL,
  `name` varchar(45) NOT NULL,
  `registration_number` varchar(45) NOT NULL,
  `ageing` int NOT NULL,
  `phone` varchar(255) NOT NULL,
  `status_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `communication_methods`
--

DROP TABLE IF EXISTS `communication_methods`;
CREATE TABLE IF NOT EXISTS `communication_methods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `method_code` varchar(45) NOT NULL,
  `method_name` varchar(45) NOT NULL,
  `description` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `method_code_UNIQUE` (`method_code`),
  UNIQUE KEY `method_name_UNIQUE` (`method_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `financial_informations`
--

DROP TABLE IF EXISTS `financial_informations`;
CREATE TABLE IF NOT EXISTS `financial_informations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `vat_number` varchar(255) NOT NULL,
  `tax_identification_number` varchar(255) NOT NULL,
  `bank_name` varchar(150) NOT NULL,
  `bank_account_number` bigint NOT NULL,
  `swift_code` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_code` varchar(45) NOT NULL,
  `role_name` varchar(45) NOT NULL,
  `description` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_code_UNIQUE` (`role_code`),
  UNIQUE KEY `role_name_UNIQUE` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role_code`, `role_name`, `description`, `updated_at`) VALUES
(1, 'surveyor', 'Surveyor', 'Inspecteur technique', '2025-06-21 23:52:07'),
(2, 'garage', 'Garage', 'Atelier de réparation automobile', '2025-06-21 23:52:07'),
(3, 'spare_part', 'Spare Part', 'Fournisseur de pièces détachées', '2025-06-21 23:52:07');

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(45) NOT NULL,
  `status_name` varchar(45) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`id`, `status_code`, `status_name`, `description`) VALUES
(1, 'new', 'New', 'Pas encore vérifier'),
(2, 'draft', 'Draft', 'Déjà commencé, pas submiter'),
(3, 'in_progress', 'In Progress', 'Déjà submiter'),
(4, 'add_part', 'Additional Part', 'Demande pièces supplementaires'),
(5, 'completed', 'Completed', 'Pyées et reparation effectué');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `created_at`, `updated_at`) VALUES
(1, '2025-06-21 23:45:45', '2025-06-21 23:45:45');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE IF NOT EXISTS `user_roles` (
  `users_id` int NOT NULL,
  `roles_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint DEFAULT '1',
  PRIMARY KEY (`users_id`,`roles_id`),
  KEY `fk_user_roles_users1_idx` (`users_id`),
  KEY `fk_user_roles_Roles1` (`roles_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `account_informations`
--
ALTER TABLE `account_informations`
  ADD CONSTRAINT `fk_account_informations_users` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `administrative_settings`
--
ALTER TABLE `administrative_settings`
  ADD CONSTRAINT `fk_administrative_settings_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `admin_settings_communications`
--
ALTER TABLE `admin_settings_communications`
  ADD CONSTRAINT `fk_admin_settings_communication_administrative_settings1` FOREIGN KEY (`admin_setting_id`) REFERENCES `administrative_settings` (`users_id`),
  ADD CONSTRAINT `fk_admin_settings_communication_communication_methods1` FOREIGN KEY (`method_id`) REFERENCES `communication_methods` (`id`);

--
-- Constraints for table `assignment`
--
ALTER TABLE `assignment`
  ADD CONSTRAINT `fk_assignment_claims1` FOREIGN KEY (`claims_id`) REFERENCES `claims` (`id`),
  ADD CONSTRAINT `fk_assignment_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `financial_informations`
--
ALTER TABLE `financial_informations`
  ADD CONSTRAINT `fk_financial_informations_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `fk_user_roles_Roles1` FOREIGN KEY (`roles_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `fk_user_roles_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
