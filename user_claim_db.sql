-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 08, 2025 at 06:56 AM
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
-- Database: `user_claim_db`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `AuthentificateUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AuthentificateUser` (IN `p_email_address` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_password_match INT DEFAULT 0;

    -- Vérifier que l'email existe
    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.account_informations
    WHERE email_address = p_email_address;

    IF v_exists = 0 THEN
        -- Si l'email est introuvable
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email introuvable.';
    ELSE
        -- Vérifier le mot de passe
        SELECT COUNT(*) INTO v_password_match
        FROM user_claim_db.account_informations
        WHERE email_address = p_email_address
          AND password = p_password;

        IF v_password_match = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mot de passe incorrect.';
        ELSE
            -- Récupérer les infos de l'utilisateur
            SELECT 'ok reussi' as message;
        END IF;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `ChekEmailExists`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ChekEmailExists` (IN `p_email_address` VARCHAR(255))   BEGIN
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.account_informations
    WHERE email_address = p_email_address;

    IF v_exists = 0 THEN
        SELECT 'Email introuvable.' AS message;
    ELSE
        -- Tu pourras ici éventuellement créer un token et l’envoyer par mail
        SELECT 'Email existant, envoi du lien de réinitialisation' AS message;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `GetAllClaims`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllClaims` (IN `p_page` INT, IN `p_page_size` INT)   BEGIN
    DECLARE v_order_by VARCHAR(1000);
    DECLARE v_offset INT;
    DECLARE v_sql VARCHAR(4000);
    
    SET p_page = GREATEST(IFNULL(p_page, 1), 1); -- Garantit au moins 1
    SET p_page_size = GREATEST(IFNULL(p_page_size, 10), 10); -- Garantit au moins 10

    SET v_order_by = '';
    SET v_offset = (p_page - 1) * p_page_size;

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
            ST.status_name AS status_name,
            CL.affected
        FROM claims CL
        INNER JOIN status ST ON CL.status_id = ST.id
        ', v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);
    
    -- Exécution de la requête
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `GetAllRoles`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllRoles` (IN `p_page` INT, IN `p_page_size` INT)   BEGIN
    DECLARE v_order_by VARCHAR(1000);
    DECLARE v_offset INT;
    DECLARE v_sql VARCHAR(4000);
    
    SET p_page = GREATEST(IFNULL(p_page, 1), 1); -- Garantit au moins 1
    SET p_page_size = GREATEST(IFNULL(p_page_size, 10), 10); -- Garantit au moins 10

    SET v_order_by = '';
    SET v_offset = (p_page - 1) * p_page_size;

    -- Construction de la requête
    SET v_sql = CONCAT('
        SELECT 
            id, 
			role_code,
			role_name,
			description
        FROM roles
        ', v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);
    
    -- Exécution de la requête
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `GetAllStatus`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllStatus` ()   BEGIN
    SELECT * FROM user_claim_db.status;
END$$

DROP PROCEDURE IF EXISTS `GetAssignmentById`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAssignmentById` (IN `p_claims_number` VARCHAR(255))   BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM user_claim_db.assignment WHERE claims_number = p_claims_number
    ) THEN
        SELECT 'Numero de claim introuvable.' AS message;
    END IF;

    -- Récupérer les données
    SELECT 
        A.users_id,
        A.assignment_date,
        A.assignement_note,
        A.status_id, 
	A.claims_number
    FROM user_claim_db.assignment A
    WHERE A.claims_number = p_claims_number;
END$$

DROP PROCEDURE IF EXISTS `GetAssignmentList`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAssignmentList` (IN `p_claims_number` VARCHAR(100), IN `p_status_name` VARCHAR(45), IN `p_role_name` VARCHAR(45), IN `p_business_name` VARCHAR(150))   BEGIN
    SELECT
    	a.users_id,
        a.claims_number,
        s.status_name,
        ai.business_name,
        GROUP_CONCAT(DISTINCT r.role_name SEPARATOR ', ') AS role_names,
        a.assignment_date
    FROM assignment                 AS a
    LEFT JOIN status                AS s  ON s.id        = a.status_id
    LEFT JOIN account_informations  AS ai ON ai.users_id = a.users_id
    LEFT JOIN user_roles            AS ur ON ur.users_id = a.users_id
    LEFT JOIN roles                 AS r  ON r.id        = ur.roles_id
    WHERE  (p_claims_number  IS NULL OR p_claims_number  = '' OR a.claims_number   = p_claims_number)
       AND (p_status_name    IS NULL OR p_status_name    = '' OR s.status_name     = p_status_name)
       AND (p_role_name      IS NULL OR p_role_name      = '' OR r.role_name       = p_role_name)
       AND (p_business_name  IS NULL OR p_business_name  = '' OR ai.business_name  = p_business_name)
    GROUP BY
        a.claims_number,
        s.status_name,
        ai.business_name,
        a.assignment_date
    ORDER BY a.assignment_date DESC;
END$$

DROP PROCEDURE IF EXISTS `GetListByUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetListByUser` (IN `p_email` VARCHAR(255), IN `p_status` VARCHAR(255), IN `p_search_name` VARCHAR(255), IN `p_sort_by` VARCHAR(50), IN `p_page` INT, IN `p_page_size` INT, IN `p_search_num` VARCHAR(255), IN `p_search_reg_num` VARCHAR(255), IN `p_search_phone` VARCHAR(255))   BEGIN
    DECLARE v_where TEXT;
    DECLARE v_order_by TEXT;
    DECLARE v_offset INT;
    DECLARE v_sql TEXT;
    
    -- Définir les valeurs par défaut avec validation
    SET p_email = IFNULL(p_email, '');
    SET p_status = IFNULL(p_status, '');
    SET p_search_name = IFNULL(p_search_name, '');
    SET p_sort_by = IFNULL(p_sort_by, 'date');
    SET p_page = GREATEST(IFNULL(p_page, 1), 1); -- Garantit au moins 1
    SET p_page_size = GREATEST(IFNULL(p_page_size, 10), 10); -- Garantit au moins 1
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

    -- [Le reste de votre code reste inchangé jusqu'à la construction de la requête]

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
            ST.status_name AS status_name
        FROM claims CL
        INNER JOIN assignment A ON CL.id = A.claims_id
        INNER JOIN users US ON US.id = A.users_id
        INNER JOIN account_informations ACI ON ACI.users_id = US.id
        INNER JOIN status ST ON A.status_id = ST.id
        ', v_where, v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);

    -- Afficher la requête pour débogage
    -- SELECT v_sql AS 'Requête générée';
    
    -- Exécution de la requête
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `GetUserByRole`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByRole` (IN `p_role_id` INT)   BEGIN
    -- Vérifie que l'ID du rôle est valide
    SET p_role_id = IFNULL(p_role_id, 1); -- Valeur par défaut 1 si NULL
    
    SELECT 
        u.id AS user_id,
        ai.business_name,
        ai.email_address ,
        r.role_name
    FROM 
        `users` AS u 
	LEFT JOIN
		account_informations ai ON u.id = ai.users_id
    LEFT JOIN 
        user_roles AS ur ON u.id = ur.users_id 
    LEFT JOIN 
        roles AS r ON ur.roles_id = r.id 
    WHERE 
        r.id = p_role_id;
END$$

DROP PROCEDURE IF EXISTS `GetUserProfile`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserProfile` (IN `p_email_address` VARCHAR(255))   BEGIN
    SELECT
        AI.business_name,
        AI.business_registration_number,
        AI.business_address,
        AI.city,
        AI.postal_code,
        AI.phone_number,
        AI.email_address,
        AI.website,
        AI.backup_email,
        AI.password,
        
        FI.vat_number,
        FI.tax_identification_number,
        FI.bank_name,
        FI.bank_account_number,
        FI.swift_code,

        ASG.primary_contact_name,
        ASG.primary_contact_post,
        ASG.notification,
        ASG.updated_at AS administrative_updated_at

    FROM user_claim_db.users U
    LEFT JOIN user_claim_db.account_informations AI
        ON U.id = AI.users_id
    LEFT JOIN user_claim_db.financial_informations FI
        ON U.id = FI.users_id
    LEFT JOIN user_claim_db.administrative_settings ASG
        ON U.id = ASG.users_id
    WHERE AI.email_address = p_email_address;
END$$

DROP PROCEDURE IF EXISTS `InsertAssignment`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertAssignment` (IN `p_users_id` INT, IN `p_assignment_date` DATETIME, IN `p_assignement_note` TEXT, IN `p_status_id` INT, IN `p_claims_number` VARCHAR(100))   BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM   user_claim_db.claims
                   WHERE  number = p_claims_number) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Réclamation introuvable (claims_id).';
    END IF;

    IF NOT EXISTS (SELECT 1
                   FROM   user_claim_db.users
                   WHERE  id = p_users_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Utilisateur introuvable (users_id).';
    END IF;
    INSERT INTO user_claim_db.assignment (
        users_id,
        assignment_date,
        assignement_note,
        status_id,
        claims_number
    ) VALUES (
        p_users_id,
        p_assignment_date,
        p_assignement_note,
        p_status_id,
        p_claims_number
    );

    UPDATE user_claim_db.claims
    SET    affected = 1
    WHERE  number   = p_claims_number;   -- ou id = p_claims_id selon votre clé
END$$

DROP PROCEDURE IF EXISTS `UpdateAdminSettings`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAdminSettings` (IN `p_email_address` VARCHAR(255), IN `p_primary_contact_name` VARCHAR(100), IN `p_primary_contact_post` VARCHAR(100), IN `p_notification` BOOLEAN)   BEGIN
    DECLARE v_users_id INT;

    -- Récupérer le users_id
    SELECT users_id INTO v_users_id
    FROM user_claim_db.account_informations
    WHERE email_address = p_email_address
    LIMIT 1;

    IF v_users_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email introuvable.';
    END IF;

    -- Mise à jour
    UPDATE user_claim_db.administrative_settings
    SET primary_contact_name = p_primary_contact_name,
        primary_contact_post = p_primary_contact_post,
        notification = p_notification,
        updated_at = NOW()
    WHERE users_id = v_users_id;
    
     -- Vérification
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucune mise à jour effectuée. Email introuvable ou site déjà à jour.';
    ELSE
        SELECT 'Mise à jour réussie' AS message;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `UpdateAssignment`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAssignment` (IN `p_users_id` INT, IN `p_assignment_date` DATETIME, IN `p_assignement_note` TEXT, IN `p_status_id` INT, IN `p_claims_number` VARCHAR(100))   BEGIN
    -- Vérifier que l'enregistrement existe
    IF NOT EXISTS (
        SELECT 1 FROM user_claim_db.assignment WHERE claims_number = p_claims_number
    ) THEN 
        SELECT 'Numero de claim introuvable (claims_number).' AS message;
    END IF;


    UPDATE user_claim_db.assignment
    SET
	claims_number = p_claims_number,
        users_id = p_users_id,
        assignment_date = NOW(),
        assignement_note = p_assignement_note,
        status_id = p_status_id
    WHERE claims_number = p_claims_number 
    AND users_id = p_users_id;

END$$

DROP PROCEDURE IF EXISTS `UpdateUserPassword`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserPassword` (IN `p_email_address` VARCHAR(255), IN `p_new_password` VARCHAR(250))   BEGIN
    UPDATE user_claim_db.account_informations
    SET password = p_new_password
    WHERE email_address = p_email_address;
   
   -- Vérification
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucune mise à jour effectuée. Email introuvable ou site déjà à jour.';
    ELSE
        SELECT 'Mise à jour mot de passe réussie' AS message;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `UpdateUserWebsite`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserWebsite` (IN `p_email_address` VARCHAR(255), IN `p_new_website` VARCHAR(255))   BEGIN
    -- Mise à jour du champ website
    UPDATE user_claim_db.account_informations
    SET website = p_new_website
    WHERE email_address = p_email_address;

    -- Vérification
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucune mise à jour effectuée. Email introuvable ou site déjà à jour.';
    ELSE
        SELECT 'Mise à jour site web réussie' AS message;
    END IF;
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
  `backup_email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_address_UNIQUE` (`email_address`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `account_informations`
--

INSERT INTO `account_informations` (`id`, `users_id`, `business_name`, `business_registration_number`, `business_address`, `city`, `postal_code`, `phone_number`, `email_address`, `password`, `website`, `backup_email`) VALUES
(1, 1, 'Brondon', '48 AG 23', 'Squard Orchard', 'Quatre Bornes', '7000', '56589857', 'tojo@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.test5.com', ''),
(2, 2, 'Christofer', '1 JN 24', 'La Louis', 'Quatre Bornes', '7120', '57896532', 'rene@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.rene.com', ''),
(3, 3, 'Kierra', '94 NOV 06', 'Moka', 'Saint Pierre', '7520', '54789512', 'raharison@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.raharison.com', ''),
(4, 4, 'Surveyor 2', 'Surveyor 2', 'addr Surveyor 2', 'Quatre bornes', '7200', '55678923', 'surveyor2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.surveyor.com', ''),
(5, 5, 'Surveyor 3', 'Surveyor 2', 'Addr Surveyor 2', 'Quatre Bornes', '7500', '55897899', 'surveyor3@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.surveyor3.com', ''),
(6, 6, 'Garage 1', 'Garage 1', 'Addr Garage 1', 'Quatre bornes', '7200', '45677444', 'garage2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.garage2.com', ''),
(7, 7, 'Spare Part 2', 'Spare Part 2', 'Addr Spare Part 2', 'Quatre bornes', '7200', '34667777', 'sparepart@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.sparepart2.com', '');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `administrative_settings`
--

INSERT INTO `administrative_settings` (`id`, `users_id`, `primary_contact_name`, `primary_contact_post`, `notification`, `updated_at`) VALUES
(1, 1, 'Test contact 77', 'Test contact 55', '0', '2025-06-27 09:50:26');

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
  `claims_number` varchar(100) NOT NULL,
  `users_id` int NOT NULL,
  `assignment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `assignement_note` text,
  `status_id` int NOT NULL,
  KEY `fk_assignment_status1_idx` (`status_id`),
  KEY `fk_assignment_users1` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `assignment`
--

INSERT INTO `assignment` (`claims_number`, `users_id`, `assignment_date`, `assignement_note`, `status_id`) VALUES
('M0119921', 1, '2025-07-04 11:03:40', NULL, 2),
('M0119923', 5, '2025-07-03 20:00:00', 'test', 1),
('M0119921', 6, '2025-07-03 20:00:00', 'Test affectation garage 1', 1);

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
  `affected` tinyint DEFAULT NULL,
  `status_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `fk_claims_status1_idx` (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `claims`
--

INSERT INTO `claims` (`id`, `received_date`, `number`, `name`, `registration_number`, `ageing`, `phone`, `affected`, `status_id`) VALUES
(1, '2025-06-29', 'M0119921', 'Brandon Philipps', '9559 AG 23', 120, '55487956', 1, 1),
(2, '2025-06-30', 'M0119922', 'Christofer Curtis', '1 JN 24', 96, '54789632', 0, 1),
(3, '2025-06-01', 'M0119923', 'Kierra', '95 ZN 15', 72, '58796301', 1, 1),
(4, '2025-07-02', 'M0119924', 'Test dev 1', '1525 ZN 45', 48, '48503895', 0, 1),
(5, '2025-07-03', 'M0119925', 'test dev 3', '1895 JN 24', 24, '55879631', 0, 1);

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role_code`, `role_name`, `description`, `updated_at`) VALUES
(1, 'surveyor', 'Surveyor', 'Utilisateur qui fait la vérificatoin', '2025-06-26 22:08:34'),
(2, 'garage', 'Garage', 'Utilisateur qui fait la réparation', '2025-06-26 22:08:34'),
(3, 'spare_part', 'Spare Part', 'Utilisateur qui est le fournisseur des pièces', '2025-06-26 22:09:57'),
(4, 'car_rentale', 'Car Rentale', 'Utilisateur pour la location voiture', '2025-06-26 22:09:57');

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(45) DEFAULT NULL,
  `status_name` varchar(45) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`id`, `status_code`, `status_name`, `description`) VALUES
(1, 'new', 'New', 'Première statut des claims après affectatin'),
(2, 'draft', 'Draft', 'Status pendant intervention d\'un utilisateur'),
(3, 'in_progress', 'In Progress', 'Status après submit des formulaires'),
(4, 'completed', 'Completed', 'Status quand le paiement est effectué'),
(5, 'rejected', 'Rejected', 'Statut pour rejecter un claim');

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `created_at`, `updated_at`) VALUES
(1, '2025-06-23 07:54:40', '2025-06-23 07:54:40'),
(2, '2025-06-23 07:54:46', '2025-06-23 07:54:46'),
(3, '2025-06-23 07:54:53', '2025-06-23 07:54:53'),
(4, '2025-06-26 22:49:06', '2025-06-26 22:49:06'),
(5, '2025-06-26 22:49:14', '2025-06-26 22:49:14'),
(6, '2025-06-26 22:53:25', '2025-06-26 22:53:25'),
(7, '2025-06-26 22:53:30', '2025-06-26 22:53:30');

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
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`users_id`, `roles_id`, `assigned_at`, `is_active`) VALUES
(1, 1, '2025-06-26 22:47:37', 1),
(2, 2, '2025-06-26 22:47:37', 1),
(3, 3, '2025-06-26 22:48:09', 1),
(4, 1, '2025-06-26 22:53:08', 1),
(5, 1, '2025-06-26 22:53:08', 1),
(6, 2, '2025-06-26 22:56:16', 1),
(7, 3, '2025-06-26 22:56:16', 1);

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
  ADD CONSTRAINT `fk_assignment_status1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`),
  ADD CONSTRAINT `fk_assignment_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `claims`
--
ALTER TABLE `claims`
  ADD CONSTRAINT `fk_claims_status1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`);

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
