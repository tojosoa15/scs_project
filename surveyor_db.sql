-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 25, 2025 at 07:58 AM
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

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `GetClaimDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetClaimDetails` (IN `p_claim_number` VARCHAR(100), IN `p_email` VARCHAR(100))   BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Vérifier que le claim existe ET que l'email correspond
    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA
        ON CL.number = SA.claims_number
    INNER JOIN surveyor_db.survey S
        ON S.claim_number = CL.number
    INNER JOIN user_claim_db.users U
        ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC
        ON AC.users_id = U.id
    WHERE CL.number = p_claim_number
      AND AC.email_address = p_email;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Claim introuvable ou email incorrect.';
    END IF;

    -- Sélectionner les détails du véhicule, survey, documents, estimate, parts et labour
    SELECT
        -- Vehicle Information
        CL.number AS claim_number,
        ST.status_name AS status_name,
        CL.*,
        DATEDIFF(CURDATE(), CL.received_date) AS ageing,
        CL.phone AS mobile_number,
        VI.*,

        -- Survey Information
        SI.*,

        -- Documents
        (
            SELECT GROUP_CONCAT(D.attachements SEPARATOR ', ')
            FROM surveyor_db.documents D
            INNER JOIN surveyor_db.survey S2
                ON S2.id = D.survey_information_id
            WHERE S2.claim_number = CL.number
        ) AS document_names,

        -- Estimate of Repairs
        EOR.*,

        -- Part Details
        PD.*,

        -- Labour Details
        LD.*

    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA
        ON CL.number = SA.claims_number
    INNER JOIN user_claim_db.status ST
        ON SA.status_id = ST.id
    LEFT JOIN surveyor_db.survey S
        ON S.claim_number = CL.number
    LEFT JOIN surveyor_db.survey_information SI
        ON SI.verification_id = S.id
    LEFT JOIN surveyor_db.vehicle_information VI
        ON VI.verification_id = S.id
    INNER JOIN user_claim_db.users U
        ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC
        ON AC.users_id = U.id
    LEFT JOIN surveyor_db.estimate_of_repair EOR
        ON EOR.verification_id = S.id
    LEFT JOIN surveyor_db.part_detail PD
        ON PD.estimate_of_repair_id = EOR.id
    LEFT JOIN surveyor_db.labour_detail LD
        ON LD.part_detail_id = PD.id
    WHERE CL.number = p_claim_number
      AND AC.email_address = p_email
      limit 1;
END$$

DROP PROCEDURE IF EXISTS `GetSummary`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSummary` (IN `p_claim_number` VARCHAR(100), IN `p_email` VARCHAR(255))  DETERMINISTIC BEGIN 
    DECLARE v_exists INT DEFAULT 0;

    -- Vérification du claim et de l'email
    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA ON CL.number = SA.claims_number
    INNER JOIN surveyor_db.survey S ON S.claim_number = CL.number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Claim introuvable ou email incorrect.';
    END IF;

    -- 1. Survey Information
    SELECT
        SI.*,
        (
            SELECT GROUP_CONCAT(D.attachements SEPARATOR ', ')
            FROM surveyor_db.documents D
            INNER JOIN surveyor_db.survey S2 ON S2.id = D.survey_information_id
            WHERE S2.claim_number = p_claim_number
        ) AS document_names
    FROM surveyor_db.survey_information SI
    INNER JOIN surveyor_db.survey S ON SI.verification_id = S.id
    INNER JOIN user_claim_db.claims CL ON S.claim_number = CL.number
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = S.surveyor_id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    -- 2. Vehicle Information
    SELECT
        CL.number AS claim_number,
        ST.status_name,
        CL.phone AS mobile_number,
        CL.*,
        VI.*
    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA ON CL.number = SA.claims_number
    INNER JOIN user_claim_db.status ST ON SA.status_id = ST.id
    INNER JOIN surveyor_db.survey S ON S.claim_number = CL.number
    LEFT JOIN surveyor_db.vehicle_information VI ON VI.verification_id = S.id
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    -- 3. Part Details
    SELECT
        PD.*,
        ROUND(SUM(PD.cost_part), 2) AS parts_cost,
        ROUND(SUM(PD.discount_part), 2) AS parts_discount,
        ROUND(SUM((PD.cost_part - PD.discount_part) * 
                  (1 + (PD.vat_part / NULLIF(PD.cost_part, 0)))), 2) AS parts_total
    FROM surveyor_db.part_detail PD
    INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
    INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
    INNER JOIN user_claim_db.claims CL ON S.claim_number = CL.number
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = S.surveyor_id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email
    GROUP BY PD.id;

    -- 4. Labour Details
    SELECT
        LD.*,
        ROUND(
            (LD.number_of_hours * LD.hourly_const_labour - LD.discount_labour) * 
            (1 + (LD.vat_labour / NULLIF((LD.number_of_hours * LD.hourly_const_labour), 0)))
        , 2) AS labour_cost
    FROM surveyor_db.labour_detail LD
    INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
    INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
    INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
    INNER JOIN user_claim_db.claims CL ON S.claim_number = CL.number
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = S.surveyor_id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    -- 5. Grand Totals
    SELECT
        -- Grand Total Cost
        ROUND((
            SELECT SUM(PD.cost_part)
            FROM surveyor_db.part_detail PD
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ) +
        (
            SELECT SUM(LD.number_of_hours * LD.hourly_const_labour)
            FROM surveyor_db.labour_detail LD
            INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ), 2) AS grand_total_cost,

        -- Grand Total Discount
        ROUND((
            SELECT SUM(PD.discount_part)
            FROM surveyor_db.part_detail PD
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ) +
        (
            SELECT SUM(LD.discount_labour)
            FROM surveyor_db.labour_detail LD
            INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ), 2) AS grand_total_discount,

        -- Grand Total VAT
        ROUND((
            SELECT SUM(PD.vat_part)
            FROM surveyor_db.part_detail PD
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ) +
        (
            SELECT SUM(LD.vat_labour)
            FROM surveyor_db.labour_detail LD
            INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ), 2) AS grand_total_vat,

        -- Grand Total Final
        ROUND((
            SELECT SUM((PD.cost_part - PD.discount_part) * 
                       (1 + (PD.vat_part / NULLIF(PD.cost_part, 0))))
            FROM surveyor_db.part_detail PD
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ) +
        (
            SELECT SUM((LD.number_of_hours * LD.hourly_const_labour - LD.discount_labour) * 
                       (1 + (LD.vat_labour / NULLIF((LD.number_of_hours * LD.hourly_const_labour), 0))))
            FROM surveyor_db.labour_detail LD
            INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
            INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
            INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
            WHERE S.claim_number = p_claim_number
        ), 2) AS grand_total;
END$$

DROP PROCEDURE IF EXISTS `GetTotalReport`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTotalReport` (IN `p_claim_number` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_section` VARCHAR(45))  DETERMINISTIC BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Vérifier l'existence du claim et de l'email
    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA ON CL.number = SA.claims_number
    INNER JOIN surveyor_db.survey S ON S.claim_number = CL.number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Claim introuvable ou email incorrect.';
    END IF;

    -- Afficher seulement selon la section
    IF p_section = 'labour' THEN

        SELECT
            LD.id,
            ROUND((LD.hourly_const_labour - LD.discount_labour) * (1 + LD.vat_labour / NULLIF(LD.hourly_const_labour, 0)), 2) AS total_labour_ttc
        FROM surveyor_db.labour_detail LD
        INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
        INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
        INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
        INNER JOIN user_claim_db.claims CL ON S.claim_number = CL.number
        INNER JOIN user_claim_db.account_informations AC ON AC.users_id = S.surveyor_id
        WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    ELSEIF p_section = 'part' THEN

        SELECT
            PD.id,
            ROUND((PD.cost_part - PD.discount_part) * (1 + PD.vat_part / NULLIF(PD.cost_part, 0)), 2) AS total_part_ttc
        FROM surveyor_db.part_detail PD
        INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
        INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
        INNER JOIN user_claim_db.claims CL ON S.claim_number = CL.number
        INNER JOIN user_claim_db.account_informations AC ON AC.users_id = S.surveyor_id
        WHERE CL.number = p_claim_number AND AC.email_address = p_email;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Section invalide. Utilisez "part" ou "labour".';
    END IF;

END$$

DROP PROCEDURE IF EXISTS `SpVerificationProcessSurveyor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SpVerificationProcessSurveyor` (IN `p_claim_number` VARCHAR(100), IN `p_surveyor_id` INT, IN `p_status` BOOLEAN, IN `p_current_step` VARCHAR(50), IN `p_json_data` JSON)   BEGIN
    DECLARE v_verification_id INT;
    DECLARE v_estimate_of_repair_id INT;
    DECLARE v_part_detail_id INT;

    IF p_current_step = 'step_1' THEN
        -- Insert dans Survey
        INSERT INTO survey (surveyor_id, current_step, status_id, claim_number)
        VALUES (p_surveyor_id, p_current_step, p_status, p_claim_number);

        SET v_verification_id = LAST_INSERT_ID();

        -- Vehicle information depuis JSON
        INSERT INTO vehicle_information (
            verification_id, make, model, cc, fuel_type, transmission, engime_no, chasisi_no, vehicle_no, color, odometer_reading, is_the_vehicle_total_loss, condition_of_vehicle, place_of_survey, point_of_impact
        ) VALUES (
            v_verification_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.make')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.model')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.cc')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.fuel_type')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.transmission')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.engime_no')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.chasisi_no')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.vehicle_no')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.color')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.odometer_reading')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.is_the_vehicle_total_loss')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.condition_of_vehicle')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.place_of_survey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.point_of_impact'))
        );

        -- Mettre à jour l'étape
        UPDATE survey
        SET current_step = p_current_step
        WHERE id = v_verification_id;

    ELSEIF p_current_step = 'step_2' THEN
        SELECT id INTO v_verification_id
        FROM survey
        WHERE claim_number = p_claim_number AND surveyor_id = p_surveyor_id
        LIMIT 1;

        -- Survey information depuis JSON
        INSERT INTO survey_information (
            verification_id, garage, garage_address, garage_contact_number, eor_value, invoice_number, survey_type, date_of_survey, time_of_survey, pre_accident_valeur, showroom_price, wrech_value, excess_applicable
        )
        VALUES (
            v_verification_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.garage')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.garage_address')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.garage_contact_number')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.eor_value')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.invoice_number')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.survey_type')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.date_of_survey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.time_of_survey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.pre_accident_valeur')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.showroom_price')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.wrech_value')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.excess_applicable'))
        );

        -- Mettre à jour l'étape
        UPDATE survey
        SET current_step = p_current_step
        WHERE id = v_verification_id;

    ELSEIF p_current_step = 'step_3' THEN
        SELECT id INTO v_verification_id
        FROM survey
        WHERE claim_number = p_claim_number AND surveyor_id = p_surveyor_id
        LIMIT 1;

        -- Estimate of repair depuis JSON
        INSERT INTO estimate_of_repair (verification_id, current_editor, remarks)
        VALUES (
            v_verification_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.current_editor')),
            JSON_EXTRACT(p_json_data, '$.remarks')
        );

        SET v_estimate_of_repair_id = LAST_INSERT_ID();

        -- Part detail information depuis JSON
        -- Boucle sur le tableau des pièces
        SET @i = 0;
        SET @total_parts = JSON_LENGTH(JSON_EXTRACT(p_json_data, '$.parts'));

        WHILE @i < @total_parts DO
            -- Insertion dans part_detail
            INSERT INTO part_detail (
                estimate_of_repair_id,
                part_name,
                quantity,
                supplier,
                quality,
                cost_part,
                discount_part,
                vat_part,
                part_total
            ) VALUES (
                v_estimate_of_repair_id,
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].part_name'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].quantity')),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].supplier'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].quality'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].cost_part')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].discount_part')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].vat_part')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].part_total'))
            );

            SET v_part_detail_id = LAST_INSERT_ID();

            -- Insertion correspondante dans labour_detail
            INSERT INTO labour_detail (
                part_detail_id,
                eor_or_surveyor,
                activity,
                number_of_hours,
                hourly_const_labour,
                discount_labour,
                vat_labour,
                labour_total
            ) VALUES (
                v_part_detail_id,
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].eor_or_surveyor'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].activity'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].number_of_hours')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].hourly_const_labour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].discount_labour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].vat_labour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].labour_total'))
            );

            SET @i = @i + 1;
        END WHILE;

        -- Mettre à jour l'étape
        UPDATE survey
        SET current_step = p_current_step
        WHERE id = v_verification_id;

    ELSEIF p_current_step = 'step_4' THEN
        SELECT id INTO v_verification_id
        FROM survey
        WHERE claim_number = p_claim_number AND surveyor_id = p_surveyor_id
        LIMIT 1;

        -- Mettre à jour l'étape
        UPDATE survey
        SET current_step = p_current_step, status_id = 1
        WHERE id = v_verification_id;
    END IF;

    -- Tu peux faire un SELECT de retour ici si tu veux
    SELECT 'Mise à jour verification réussie' AS message;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `additional_labour_detail`
--

DROP TABLE IF EXISTS `additional_labour_detail`;
CREATE TABLE IF NOT EXISTS `additional_labour_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estimate_of_repair_id` int DEFAULT NULL,
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
-- Table structure for table `doctrine_migration_versions`
--

DROP TABLE IF EXISTS `doctrine_migration_versions`;
CREATE TABLE IF NOT EXISTS `doctrine_migration_versions` (
  `version` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
CREATE TABLE IF NOT EXISTS `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int DEFAULT NULL,
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
  `verification_id` int DEFAULT NULL,
  `current_editor` enum('eor','surveyor') DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`id`),
  KEY `fk_estimate_of_repair_verification1_idx` (`verification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `estimate_of_repair`
--

INSERT INTO `estimate_of_repair` (`id`, `verification_id`, `current_editor`, `remarks`) VALUES
(1, 1, '', '\"Plusieurs réparations à effectuer\"');

-- --------------------------------------------------------

--
-- Table structure for table `labour_detail`
--

DROP TABLE IF EXISTS `labour_detail`;
CREATE TABLE IF NOT EXISTS `labour_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `part_detail_id` int DEFAULT NULL,
  `eor_or_surveyor` enum('eor','surveyor') NOT NULL,
  `activity` varchar(45) NOT NULL,
  `number_of_hours` int NOT NULL,
  `hourly_const_labour` float NOT NULL,
  `discount_labour` float NOT NULL,
  `vat_labour` varchar(255) NOT NULL,
  `labour_total` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_labour_detail_part_detail1_idx` (`part_detail_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `labour_detail`
--

INSERT INTO `labour_detail` (`id`, `part_detail_id`, `eor_or_surveyor`, `activity`, `number_of_hours`, `hourly_const_labour`, `discount_labour`, `vat_labour`, `labour_total`) VALUES
(1, 1, 'eor', 'Remplacement pare-chocs', 2, 800, 100, '15', 1500),
(2, 2, 'surveyor', 'Installation phare', 1, 600, 50, '15', 900);

-- --------------------------------------------------------

--
-- Table structure for table `part_detail`
--

DROP TABLE IF EXISTS `part_detail`;
CREATE TABLE IF NOT EXISTS `part_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estimate_of_repair_id` int DEFAULT NULL,
  `part_name` varchar(150) NOT NULL,
  `quantity` int NOT NULL,
  `supplier` varchar(255) NOT NULL,
  `quality` varchar(45) NOT NULL,
  `cost_part` float NOT NULL,
  `discount_part` float NOT NULL,
  `vat_part` varchar(255) NOT NULL,
  `part_total` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_part_detail_estimate_of_repair1_idx` (`estimate_of_repair_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `part_detail`
--

INSERT INTO `part_detail` (`id`, `estimate_of_repair_id`, `part_name`, `quantity`, `supplier`, `quality`, `cost_part`, `discount_part`, `vat_part`, `part_total`) VALUES
(1, 1, 'Pare-chocs arrière', 1, 'Garage Spare Ltd', 'Original', 10000, 500, '15', 11000),
(2, 1, 'Phare avant', 1, 'AutoParts Inc', 'OEM', 5000, 250, '15', 5500);

-- --------------------------------------------------------

--
-- Table structure for table `picture_of_domage_car`
--

DROP TABLE IF EXISTS `picture_of_domage_car`;
CREATE TABLE IF NOT EXISTS `picture_of_domage_car` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int DEFAULT NULL,
  `path` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_picture_of_domage_car_survey_information1_idx` (`survey_information_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `refresh_token` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `valid` datetime NOT NULL,
  PRIMARY KEY (`refresh_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`refresh_token`, `username`, `valid`) VALUES
('04193fe1-3e8d-4507-a5ac-090842eac144', 'valentinmagde@gmail.com', '2025-08-10 10:00:59'),
('07ee93b4-971d-44bf-921c-e9e1068522e7', 'rene@gmail.com', '2025-08-10 09:40:51'),
('0a12917f-f971-4499-a24e-226c21b8b15e', 'valentinmagde@gmail.com', '2025-08-10 09:45:40'),
('0a9c5e66-b072-4ad3-8131-c3553899d8fb', 'tojo@gmail.com', '2025-08-24 06:59:48'),
('12e5901136bf8e0f3fb57cfc5a9384c4e544be94de6729acc78b37e55cd6e3641e9a7f2444fecf6ff524d884b5e091e4b5b7e732d9c8cea76fd41522b8519d59', 'rene@gmail.com', '2025-08-09 09:41:16'),
('1388399b-3b24-4ab1-9489-ea7b79d946c9', 'rene@gmail.com', '2025-08-11 11:17:28'),
('1a47fb10-a60e-4ff7-9834-02f58cedab65', 'rene@gmail.com', '2025-08-10 11:14:41'),
('1b9bfe43-68e6-4de9-b3e3-5c2fd3731179', 'rene@gmail.com', '2025-08-15 22:55:23'),
('1dd546f6-00e4-412a-89a1-e163de901067', 'rene@gmail.com', '2025-08-10 10:34:38'),
('3e786636c3cb31a82c5ee4dba76c77e3b4ef88f0870dff2f17ff321d982c634ab433b11c1dc97e26581610e3c933c7fefada4bb45e6f261817dee4c7ac8499ba', 'rene@gmail.com', '2025-08-14 22:18:42'),
('571d20a9-86aa-41b2-9074-3e0d34a33191', 'valentinmagde@gmail.com', '2025-08-10 09:59:10'),
('5e097650-0262-4017-bd0c-0fa86f9191fe', 'rene@gmail.com', '2025-08-15 11:10:51'),
('6df418e0-2cdf-4dcd-8ce1-319b334fc44a', 'rene@gmail.com', '2025-08-18 11:23:36'),
('7663e756-a58e-4fa1-98fb-2cbf2776acb8', 'rene@gmail.com', '2025-08-17 10:48:52'),
('809b53a5-9afd-49a1-9c54-fad92090cf1f', 'valentinmagde@gmail.com', '2025-08-11 10:59:07'),
('80ea5930-35e0-4c06-9c4d-e63bdc117fe1', 'rene@gmail.com', '2025-08-10 10:36:37'),
('84095067-18ae-4817-8608-95dbf29993b1', 'rene@gmail.com', '2025-08-22 06:15:04'),
('867287b0-899f-4fdd-9337-1df29b8e6a01', 'rene@gmail.com', '2025-08-10 11:07:53'),
('87d2a352-6675-42f7-8b0b-7198585eb402', 'tojo@gmail.com', '2025-08-24 10:09:15'),
('8a6d45d718f9506bde2a7cddad03f2251075e872b18210bc2ada44f2cde50e94d7b3472127e46611555faadc39a0f8b4f8245f00e0ffc95f58e776a9b45b5051', 'rene@gmail.com', '2025-08-10 10:49:47'),
('8b62ac6b-29a9-4697-82e2-2361a1d254ef', 'rene@gmail.com', '2025-08-10 10:34:52'),
('94ddf92f-9e36-4ff3-90f4-5fc1f259632b', 'rene@gmail.com', '2025-08-16 10:03:10'),
('9f63d5d1-ad09-45b5-aae8-035804a56ff4', 'rene@gmail.com', '2025-08-23 06:44:51'),
('a5071147-d7c4-474d-af51-1237bcd020ce', 'rene@gmail.com', '2025-08-23 09:35:36'),
('b31848c1-86b5-4a29-809f-4e7c3aada01c', 'rene@gmail.com', '2025-08-23 10:00:17'),
('ba8618e5-8895-4ae8-9138-8213a3ffe674', 'valentinmagde@gmail.com', '2025-08-10 10:19:58'),
('be98df6a-8251-47f1-828d-2f0909f39e45', 'rene@gmail.com', '2025-08-16 07:56:37'),
('bff7ec0b-8eb4-4e4e-b080-1ede23058245', 'rene@gmail.com', '2025-08-22 10:02:39'),
('c0a8fa04-9fd1-4ccd-ba8d-652119112e08', 'rene@gmail.com', '2025-08-17 09:39:37'),
('c10ec606-1be5-470b-8894-49a6e82513a7', 'valentinmagde@gmail.com', '2025-08-25 07:38:36'),
('cd9bdbc7-bdf2-403f-99c0-3b6f3b1d9959', 'rene@gmail.com', '2025-08-17 07:24:18'),
('ce18acc7-1f25-434f-b936-f4fc781c54ef', 'tojo@gmail.com', '2025-08-25 06:50:45'),
('cf821452-4f7c-47cd-b46f-2aea6b1b9fd3', 'valentinmagde@gmail.com', '2025-08-11 10:59:54'),
('d54dabbf6b471ac5ff37a5b0141c4310327bd28ab2bb16789c7cb577d02c165161e17c76d328bd98c2d9646fa6db273c1b8d8d553c5347176f7020e9b3ddcaab', 'rene@gmail.com', '2025-08-14 22:02:43'),
('d695766b-ff4d-48d6-a3f1-60b4a21ccdf1', 'rene@gmail.com', '2025-08-10 11:05:15'),
('d6a1193f-5551-4198-8e06-471f06225ac6', 'tojo@gmail.com', '2025-08-23 12:28:28'),
('e0080c9f-8357-47ef-bd12-d4146e183f51', 'rene@gmail.com', '2025-08-16 12:23:21'),
('e6f8804a-6ab5-48f2-9b2f-457accf412c5', 'tojo@gmail.com', '2025-08-24 12:00:32'),
('e7458cbe4adf6f4028c892f934465bf4e9138984f65f6df8eb53bef686fd483370e42fdee00e70bd1af5003f6c028869f66e1ab092fecf2f845aa0e713dc1479', 'rene@gmail.com', '2025-08-09 09:36:03'),
('e808c1191a1aeae9a89e24f23764844cb829f410c5bcb4ede2a10ace5766565afd5072d6148836da06433870c0dacc71cb485c1c5dac119906d8b376df19ed4a', 'rene@gmail.com', '2025-08-09 11:37:17'),
('ec7ea226-742b-4d60-b4bf-137b82694d7e', 'tojo@gmail.com', '2025-08-23 10:00:38'),
('f1a30243-1ad1-461d-a545-0bd6be41ab8b', 'rene@gmail.com', '2025-08-10 11:47:03'),
('f382bd94-c6a8-4363-8f3b-776862de59c1', 'rene@gmail.com', '2025-08-20 19:32:27'),
('f700a981-4b89-47b9-bd40-8da07766a7b8', 'rene@gmail.com', '2025-08-10 10:52:59'),
('f724a2fa-6513-44e9-947b-fc90cd889cd3', 'rene@gmail.com', '2025-08-22 08:21:24'),
('f85264ae-9cf4-476b-8553-3781df976369', 'rene@gmail.com', '2025-08-14 06:46:09');

-- --------------------------------------------------------

--
-- Table structure for table `survey`
--

DROP TABLE IF EXISTS `survey`;
CREATE TABLE IF NOT EXISTS `survey` (
  `id` int NOT NULL AUTO_INCREMENT,
  `surveyor_id` int NOT NULL,
  `current_step` varchar(45) DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `claim_number` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_survey_status1_idx` (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `survey`
--

INSERT INTO `survey` (`id`, `surveyor_id`, `current_step`, `status_id`, `claim_number`) VALUES
(1, 1, 'step_3', 0, 'M0119921');

-- --------------------------------------------------------

--
-- Table structure for table `survey_information`
--

DROP TABLE IF EXISTS `survey_information`;
CREATE TABLE IF NOT EXISTS `survey_information` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `survey_information`
--

INSERT INTO `survey_information` (`id`, `verification_id`, `garage`, `garage_address`, `garage_contact_number`, `eor_value`, `invoice_number`, `survey_type`, `date_of_survey`, `time_of_survey`, `pre_accident_valeur`, `showroom_price`, `wrech_value`, `excess_applicable`) VALUES
(1, 1, 'Garage ABC', '123, Rue du Test, Quatre Bornes', '52521212', 105000, 'INV-2024-0001', 'Initial', '2025-07-17', '10:30:00', 150000, 170000, 30000, 5000);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_information`
--

DROP TABLE IF EXISTS `vehicle_information`;
CREATE TABLE IF NOT EXISTS `vehicle_information` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `vehicle_information`
--

INSERT INTO `vehicle_information` (`id`, `verification_id`, `make`, `model`, `cc`, `fuel_type`, `transmission`, `engime_no`, `chasisi_no`, `vehicle_no`, `color`, `odometer_reading`, `is_the_vehicle_total_loss`, `condition_of_vehicle`, `place_of_survey`, `point_of_impact`) VALUES
(1, 1, 'Toyota', 'Corolla', 1500, 'Petrol', 'Automatic', 'ENG123456789', 0, 'ABC-123', 'Red', 72000, 0, 'good', 'Garage ABC, Quatre Bornes', 'Front bumper');

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
