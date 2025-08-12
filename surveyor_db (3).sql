-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mar. 12 août 2025 à 10:53
-- Version du serveur : 9.1.0
-- Version de PHP : 8.2.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `surveyor_db`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `DeletedImageOfDamage`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletedImageOfDamage` (IN `p_image_id` INT)   BEGIN
    IF EXISTS (SELECT 1 FROM picture_of_damage_car WHERE id = p_image_id) THEN
        UPDATE picture_of_damage_car
        SET deleted_at = NOW()
        WHERE id = p_image_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Image introuvable';
    END IF;
END$$

DROP PROCEDURE IF EXISTS `DeletePartById`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletePartById` (IN `p_part_id` INT)   BEGIN
    IF EXISTS (SELECT 1 FROM part_detail WHERE id = p_part_id) THEN
        UPDATE part_detail
        SET deleted_at = NOW()
        WHERE id = p_part_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pièce introuvable';
    END IF;
END$$

DROP PROCEDURE IF EXISTS `GetClaimDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetClaimDetails` (IN `p_claim_number` VARCHAR(100), IN `p_email` VARCHAR(100))   BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Vérifier que le claim existe ET que l'email correspond
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

    -- Bloc 1 : Détails principaux du claim, survey, véhicule, etc.
    SELECT
        CL.number AS claim_number,
        ST.status_name,
        CL.received_date,
        CL.ageing,
        CL.name,
        CL.registration_number,
        CL.phone AS mobile_number,
        VI.make,
        VI.model,
        VI.cc,
        VI.fuel_type,
        VI.transmission,
        VI.engime_no,
        VI.chasisi_no,
        VI.vehicle_no,
        VI.color,
        VI.odometer_reading,
        VI.is_the_vehicle_total_loss,
        VI.condition_of_vehicle,
        VI.place_of_survey,
        VI.point_of_impact,
        SI.garage,
        SI.garage_address,
        SI.garage_contact_number,
        SI.eor_value,
        SI.invoice_number,
        SI.survey_type,
        SI.date_of_survey,
        SI.time_of_survey,
        SI.pre_accident_valeur,
        SI.showroom_price,
        SI.wrech_value,
        SI.excess_applicable,
        EOR.remarks

    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA ON CL.number = SA.claims_number
    INNER JOIN user_claim_db.status ST ON SA.status_id = ST.id
    LEFT JOIN surveyor_db.survey S ON S.claim_number = CL.number
    LEFT JOIN surveyor_db.survey_information SI ON SI.verification_id = S.id
    LEFT JOIN surveyor_db.vehicle_information VI ON VI.verification_id = S.id
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    LEFT JOIN surveyor_db.estimate_of_repair EOR ON EOR.verification_id = S.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email
    LIMIT 1;

    -- Bloc 2 : Liste des pièces (part_detail)
    SELECT
        PD.id,
        PD.estimate_of_repair_id,
        PD.part_name,
        PD.quantity,
        PD.supplier,
        PD.quality,
        PD.cost_part,
        PD.discount_part,
        PD.vat_part,
        PD.part_total
    FROM surveyor_db.part_detail PD
    INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
    INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
    INNER JOIN user_claim_db.claims CL ON CL.number = S.claim_number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email
      AND PD.deleted_at IS NULL;

    -- Bloc 3 : Liste des travaux (labour_detail)
    SELECT
        LD.id,
        LD.part_detail_id,
        PD.part_name,
        LD.eor_or_surveyor,
        LD.activity,
        LD.number_of_hours,
        LD.hourly_const_labour,
        LD.discount_labour,
        LD.vat_labour,
        LD.labour_total
    FROM surveyor_db.labour_detail LD
    INNER JOIN surveyor_db.part_detail PD ON LD.part_detail_id = PD.id
    INNER JOIN surveyor_db.estimate_of_repair EOR ON PD.estimate_of_repair_id = EOR.id
    INNER JOIN surveyor_db.survey S ON EOR.verification_id = S.id
    INNER JOIN user_claim_db.claims CL ON CL.number = S.claim_number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email
      AND PD.deleted_at IS NULL;

    -- Bloc 4 : Liste des documents
    SELECT 
        D.id,
        D.attachments,
        D.path
    FROM surveyor_db.documents D
    INNER JOIN surveyor_db.survey_information SI ON SI.id = D.survey_information_id
    INNER JOIN surveyor_db.survey S ON S.id = SI.verification_id
    INNER JOIN user_claim_db.claims CL ON CL.number = S.claim_number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    WHERE CL.number = p_claim_number
      AND AC.email_address = p_email;

    -- Grand total
SELECT 
    (IFNULL(SUM(PE.part_total),0) + IFNULL(SUM(LE.labour_total),0)) AS subtotal,
    (IFNULL(SUM(PE.discount_part),0) + IFNULL(SUM(LE.discount_labour),0)) AS discount_amount,
    (
        IFNULL(SUM((PE.part_total - PE.discount_part) * (PE.vat_part / 100)), 0)
        + IFNULL(SUM((LE.labour_total - LE.discount_labour) * (LE.vat_labour / 100)), 0)
    ) AS vat,
    (IFNULL(SUM(PE.part_total),0) + IFNULL(SUM(LE.labour_total),0))
      - (IFNULL(SUM(PE.discount_part),0) + IFNULL(SUM(LE.discount_labour),0))
      + (
        IFNULL(SUM((PE.part_total - PE.discount_part) * (PE.vat_part / 100)), 0)
        + IFNULL(SUM((LE.labour_total - LE.discount_labour) * (LE.vat_labour / 100)), 0)
      ) AS total
FROM surveyor_db.estimate_of_repair E
LEFT JOIN surveyor_db.part_detail PE ON PE.estimate_of_repair_id = E.id
LEFT JOIN surveyor_db.labour_detail LE ON LE.part_detail_id = PE.id
LEFT JOIN surveyor_db.survey SV ON SV.id = E.verification_id
WHERE SV.claim_number = p_claim_number
  AND PE.deleted_at IS NULL
HAVING subtotal > 0 OR discount_amount > 0 OR vat > 0 OR total > 0;

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

    -- Résultat combiné
    SELECT
        -- Survey Documents
        (SELECT GROUP_CONCAT(D.attachements SEPARATOR ', ')
         FROM surveyor_db.documents D
         INNER JOIN surveyor_db.survey S2 ON S2.id = D.survey_information_id
         WHERE S2.claim_number = p_claim_number) AS document_names,
         
        SI.*,

        -- Claim & Vehicle Info
        CL.name AS name,
        CL.number AS claim_number,
        ST.status_name,
        CL.phone AS mobile_number,
        VI.*,

        -- Part Details
        ROUND(COALESCE(SUM(PD.cost_part), 0), 2) AS cost_part,
        ROUND(COALESCE(SUM(PD.discount_part), 0), 2) AS discount_part,
        COALESCE(SUM(CAST(COALESCE(PD.vat_part, '0') AS DECIMAL)), 0) AS vat_part,
        ROUND(COALESCE(
            SUM((PD.cost_part - COALESCE(PD.discount_part, 0)) *
                (1 + CAST(COALESCE(PD.vat_part, '0') AS DECIMAL) / 100)), 0), 2
        ) AS part_total,

        -- Labour Details
        ROUND(COALESCE(SUM(LD.number_of_hours * LD.hourly_const_labour), 0), 2) AS hourly_const_labour,
        ROUND(COALESCE(SUM(LD.discount_labour), 0), 2) AS discount_labour,
        COALESCE(SUM(CAST(COALESCE(LD.vat_labour, '0') AS DECIMAL)), 0) AS vat_labour,
        ROUND(COALESCE(
            SUM((LD.number_of_hours * LD.hourly_const_labour - COALESCE(LD.discount_labour, 0)) *
                (1 + CAST(COALESCE(LD.vat_labour, '0') AS DECIMAL) / 100)), 0), 2
        ) AS labour_total,

        -- Totaux globaux
        ROUND(COALESCE(SUM(PD.cost_part) + SUM(LD.number_of_hours * LD.hourly_const_labour), 0), 2) AS cost_total,
        ROUND(COALESCE(SUM(PD.discount_part) + SUM(LD.discount_labour), 0), 2) AS discount_total,
                -- Montant total de la TVA (en roupies)
        ROUND(COALESCE(
            SUM((PD.cost_part - COALESCE(PD.discount_part, 0)) * (CAST(COALESCE(PD.vat_part, '0') AS DECIMAL) / 100))
            +
            SUM((LD.number_of_hours * LD.hourly_const_labour - COALESCE(LD.discount_labour, 0)) * (CAST(COALESCE(LD.vat_labour, '0') AS DECIMAL) / 100))
        , 0), 2) AS vat_total,

        ROUND(COALESCE(
            SUM((PD.cost_part - COALESCE(PD.discount_part, 0)) *
                (1 + CAST(COALESCE(PD.vat_part, '0') AS DECIMAL) / 100)) +
            SUM((LD.number_of_hours * LD.hourly_const_labour - COALESCE(LD.discount_labour, 0)) *
                (1 + CAST(COALESCE(LD.vat_labour, '0') AS DECIMAL) / 100))
        , 0), 2) AS total

    FROM user_claim_db.claims CL
    INNER JOIN user_claim_db.assignment SA ON CL.number = SA.claims_number
    INNER JOIN user_claim_db.status ST ON SA.status_id = ST.id
    INNER JOIN surveyor_db.survey S ON S.claim_number = CL.number
    INNER JOIN user_claim_db.users U ON U.id = S.surveyor_id
    INNER JOIN user_claim_db.account_informations AC ON AC.users_id = U.id
    INNER JOIN surveyor_db.survey_information SI ON SI.verification_id = S.id
    LEFT JOIN surveyor_db.vehicle_information VI ON VI.verification_id = S.id
    LEFT JOIN surveyor_db.estimate_of_repair EOR ON EOR.verification_id = S.id
    LEFT JOIN surveyor_db.part_detail PD ON PD.estimate_of_repair_id = EOR.id
    LEFT JOIN surveyor_db.labour_detail LD ON LD.part_detail_id = PD.id
    WHERE CL.number = p_claim_number AND AC.email_address = p_email
    GROUP BY CL.number, ST.status_name, CL.phone, SI.id, VI.id
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `GetSurvey`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSurvey` (IN `p_claim_number` VARCHAR(100), IN `p_email_address` VARCHAR(100))   BEGIN
    SELECT
        S.*
    FROM surveyor_db.survey S
    INNER JOIN user_claim_db.users U
        ON S.surveyor_id = U.id
    INNER JOIN user_claim_db.account_informations AI
        ON U.id = AI.users_id
    WHERE S.claim_number = p_claim_number
      AND AI.email_address = p_email_address;
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

DROP PROCEDURE IF EXISTS `InsertSurveyDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSurveyDetails` (IN `p_claim_number` INT(100), IN `garage` VARCHAR(100), IN `garage_address` VARCHAR(100), IN `garage_contact_number` VARCHAR(100), IN `eor_value` VARCHAR(100), IN `invoice_number` VARCHAR(100), IN `survey_type` VARCHAR(100), IN `date_of_survey` DATE, IN `time_of_survey` VARCHAR(100), IN `pre_accident_valeur` VARCHAR(100), IN `showroom_price` VARCHAR(100), IN `wrech_value` VARCHAR(100), IN `excess_applicable` VARCHAR(100))   BEGIN
    DECLARE verification_id INT;

    -- Récupération du verification_id depuis le claim_number
    SELECT id INTO verification_id
    FROM surveyor_db.survey
    WHERE claim_number = p_claim_number
    LIMIT 1;

    -- Insertion dans survey
    INSERT INTO surveyor_db.survey_information (
        verification_id,
        garage,
        garage_address,
        garage_contact_number,
        eor_value,
        invoice_number,
        survey_type,
        date_of_survey,
        time_of_survey,
        pre_accident_valeur,
        showroom_price,
        wrech_value,
        excess_applicable
    ) VALUES (
        verification_id,
        garage,
        garage_address,
        garage_contact_number,
        eor_value,
        invoice_number,
        survey_type,
        date_of_survey,
        time_of_survey,
        pre_accident_valeur,
        showroom_price,
        wrech_value,
        excess_applicable
    );
END$$

DROP PROCEDURE IF EXISTS `InsertSurveyForm`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSurveyForm` (IN `p_claim_number` VARCHAR(100), IN `p_surveyor_id` INT, IN `p_status` BOOLEAN, IN `p_current_step` VARCHAR(50), IN `p_json_data` JSON)   BEGIN
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
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.fuelType')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.transmission')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.engimeNo')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.chasisiNo')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.vehicleNo')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.color')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.odometerReading')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.isTheVehicleTotalLoss')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.conditionOfVehicle')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.placeOfSurvey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.pointOfImpact'))
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
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.garageAddress')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.garageContactNumber')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.eorValue')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.invoiceNumber')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.surveyType')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.dateOfSurvey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.timeOfSurvey')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.preAccidentValeur')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.showroomPrice')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.wrechValue')),
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.excessApplicable'))
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
            JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.currentEditor')),
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
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].partName'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].quantity')),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].supplier'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].quality'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].costPart')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].discountPart')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].vatPart')),
                JSON_EXTRACT(p_json_data, CONCAT('$.parts[', @i, '].partTotal'))
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
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].eorOrSurveyor'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].activity'))),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].numberOfHours')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].hourlyConstLabour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].discountLabour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].vatLabour')),
                JSON_EXTRACT(p_json_data, CONCAT('$.labours[', @i, '].labourTotal'))
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

DROP PROCEDURE IF EXISTS `InsertVehicleDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertVehicleDetails` (IN `p_claim_number` VARCHAR(100), IN `make` VARCHAR(100), IN `model` VARCHAR(100), IN `cc` INT, IN `fuel_type` VARCHAR(100), IN `transmission` VARCHAR(100), IN `engime_no` INT, IN `chasisi_no` INT, IN `vehicle_no` VARCHAR(100), IN `color` VARCHAR(100), IN `odometer_reading` INT, IN `is_the_vehicle_total_loss` INT, IN `condition_of_vehicle` VARCHAR(100), IN `place_of_survey` VARCHAR(100), IN `point_of_impact` VARCHAR(100))   BEGIN
    DECLARE verification_id INT;

    -- Récupérer l’ID de vérification depuis la table survey
    SELECT id INTO verification_id
    FROM surveyor_db.survey
    WHERE claim_number = p_claim_number
    LIMIT 1;

    -- Insérer les données dans vehicle_information
    INSERT INTO surveyor_db.vehicle_information (
        verification_id,
        make,
        model,
       	cc,
        fuel_type,
        transmission,
        engime_no,
        chasisi_no,
        vehicle_no,
        color,
        odometer_reading,
        is_the_vehicle_total_loss,
        condition_of_vehicle,
        place_of_survey,
        point_of_impact
    ) VALUES (
        verification_id,
        make,
        model,
       	cc,
        fuel_type,
        transmission,
        engime_no,
        chasisi_no,
        vehicle_no,
        color,
        odometer_reading,
        is_the_vehicle_total_loss,
        condition_of_vehicle,
        place_of_survey,
        point_of_impact
    );
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `additional_labour_detail`
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
-- Structure de la table `doctrine_migration_versions`
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
-- Structure de la table `documents`
--

DROP TABLE IF EXISTS `documents`;
CREATE TABLE IF NOT EXISTS `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int DEFAULT NULL,
  `attachments` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `path` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_documents_survey_information1_idx` (`survey_information_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `documents`
--

INSERT INTO `documents` (`id`, `survey_information_id`, `attachments`, `path`) VALUES
(4, 1, 'EOR1.png', 'uploads/EOR1.png'),
(5, 1, 'EOR2.png', 'http://localhost:8000/uploads/EOR2.png'),
(6, 1, 'EOR3.png', 'http://localhost:8000/uploads/EOR3.png');

-- --------------------------------------------------------

--
-- Structure de la table `estimate_of_repair`
--

DROP TABLE IF EXISTS `estimate_of_repair`;
CREATE TABLE IF NOT EXISTS `estimate_of_repair` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verification_id` int DEFAULT NULL,
  `current_editor` enum('eor','surveyor') DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`id`),
  KEY `fk_estimate_of_repair_verification1_idx` (`verification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `estimate_of_repair`
--

INSERT INTO `estimate_of_repair` (`id`, `verification_id`, `current_editor`, `remarks`) VALUES
(1, 1, '', '\"Plusieurs réparations à effectuer\"'),
(2, 4, 'surveyor', '\"accident grave\"');

-- --------------------------------------------------------

--
-- Structure de la table `labour_detail`
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
  `vat_labour` enum('0','15') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `labour_total` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_labour_detail_part_detail1_idx` (`part_detail_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `labour_detail`
--

INSERT INTO `labour_detail` (`id`, `part_detail_id`, `eor_or_surveyor`, `activity`, `number_of_hours`, `hourly_const_labour`, `discount_labour`, `vat_labour`, `labour_total`) VALUES
(1, 1, 'eor', 'Remplacement pare-chocs', 2, 800, 100, '15', 1500),
(2, 2, 'surveyor', 'Installation phare', 1, 600, 50, '15', 900),
(5, 5, 'eor', 'remplacement train avant', 3, 1200, 900, '15', 1500),
(6, 6, 'surveyor', 'remplacement capot avant', 5, 1100, 500, '15', 1500);

-- --------------------------------------------------------

--
-- Structure de la table `part_detail`
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
  `vat_part` enum('0','15') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `part_total` float DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_part_detail_estimate_of_repair1_idx` (`estimate_of_repair_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `part_detail`
--

INSERT INTO `part_detail` (`id`, `estimate_of_repair_id`, `part_name`, `quantity`, `supplier`, `quality`, `cost_part`, `discount_part`, `vat_part`, `part_total`, `deleted_at`) VALUES
(1, 1, 'Pare-chocs arrière', 1, 'Garage Spare Ltd', 'Original', 10000, 500, '15', 11000, NULL),
(2, 1, 'Phare avant', 1, 'AutoParts Inc', 'OEM', 5000, 250, '15', 5500, NULL),
(5, 2, 'Train avant', 1, 'Garage B', 'Original', 5000, 500, '15', 7000, NULL),
(6, 2, 'Capot arriere', 1, 'Garage C', 'originale', 12000, 540, '15', 15000, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `picture_of_damage_car`
--

DROP TABLE IF EXISTS `picture_of_damage_car`;
CREATE TABLE IF NOT EXISTS `picture_of_damage_car` (
  `id` int NOT NULL AUTO_INCREMENT,
  `survey_information_id` int DEFAULT NULL,
  `path` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_picture_of_domage_car_survey_information1_idx` (`survey_information_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `picture_of_damage_car`
--

INSERT INTO `picture_of_damage_car` (`id`, `survey_information_id`, `path`, `deleted_at`) VALUES
(1, 1, 'D:\\Santatra\\Pictures\\testPictures\\book-68906ea456a05.png', '2025-08-04 12:54:08'),
(2, 1, 'D:\\Santatra\\Pictures\\testPictures\\Capture-68906ea61e9e6.png', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `refresh_token` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `valid` datetime NOT NULL,
  PRIMARY KEY (`refresh_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`refresh_token`, `username`, `valid`) VALUES
('04193fe1-3e8d-4507-a5ac-090842eac144', 'valentinmagde@gmail.com', '2025-08-10 10:00:59'),
('05287934-34f3-4710-aadb-c9e8058f7869', 'santatra@gmail.com', '2025-09-08 07:09:34'),
('07c50e36-baa5-4375-8ce9-609a66f8909c', 'rene@gmail.com', '2025-08-23 06:15:18'),
('07ee93b4-971d-44bf-921c-e9e1068522e7', 'rene@gmail.com', '2025-08-10 09:40:51'),
('08dfca83-0aef-40ea-8770-fac9b0843c75', 'rene@gmail.com', '2025-08-21 07:41:29'),
('0a12917f-f971-4499-a24e-226c21b8b15e', 'valentinmagde@gmail.com', '2025-08-10 09:45:40'),
('0b7d34f0-f551-4f5b-89cf-618b727e5792', 'rene@gmail.com', '2025-08-23 09:29:42'),
('0e9e9031-8c2c-466f-8cc3-d7fff2262dd6', 'rene@gmail.com', '2025-08-21 11:39:19'),
('12e5901136bf8e0f3fb57cfc5a9384c4e544be94de6729acc78b37e55cd6e3641e9a7f2444fecf6ff524d884b5e091e4b5b7e732d9c8cea76fd41522b8519d59', 'rene@gmail.com', '2025-08-09 09:41:16'),
('1388399b-3b24-4ab1-9489-ea7b79d946c9', 'rene@gmail.com', '2025-08-11 11:17:28'),
('13e3d21b-6ac8-441a-b949-e89f98f4f2ce', 'rene@gmail.com', '2025-08-31 06:36:29'),
('19bc78a1-b36f-426a-93bd-429afed68635', 'santatra@gmail.com', '2025-09-04 07:33:16'),
('1a47fb10-a60e-4ff7-9834-02f58cedab65', 'rene@gmail.com', '2025-08-10 11:14:41'),
('1a9d651b-e08b-481a-83c5-2f60daa56c9e', 'rene@gmail.com', '2025-08-22 09:31:35'),
('1b9bfe43-68e6-4de9-b3e3-5c2fd3731179', 'rene@gmail.com', '2025-08-15 22:55:23'),
('1c52055d-49c7-4066-adf5-5ef1ac9402be', 'rene@gmail.com', '2025-08-30 06:43:48'),
('1dd546f6-00e4-412a-89a1-e163de901067', 'rene@gmail.com', '2025-08-10 10:34:38'),
('2b3fdb8c-939b-46ea-97cc-2c9665503b31', 'santatra@gmail.com', '2025-09-07 07:46:40'),
('328f6712-a272-41fb-a8b0-fe95d385fac1', 'santatra@gmail.com', '2025-09-01 06:35:10'),
('35f255cf-1180-4e5a-a88f-3a744ac2d8ed', 'santatra@gmail.com', '2025-08-31 06:47:32'),
('3a2d6d0b-9b08-4499-92c6-8bb312c68e01', 'rene@gmail.com', '2025-08-23 07:33:28'),
('3b02468e-98f5-4175-bdf8-4de8ddca9241', 'santatra@gmail.com', '2025-08-31 09:49:44'),
('3dddf212-bb47-4240-83ec-4fd99241636b', 'rene@gmail.com', '2025-08-21 07:55:30'),
('3e786636c3cb31a82c5ee4dba76c77e3b4ef88f0870dff2f17ff321d982c634ab433b11c1dc97e26581610e3c933c7fefada4bb45e6f261817dee4c7ac8499ba', 'rene@gmail.com', '2025-08-14 22:18:42'),
('4348dc7d-264a-4965-92ea-421409e24a74', 'santatra@gmail.com', '2025-09-11 08:05:40'),
('43ec8c90-a88e-448e-8976-62ee87f50f17', 'santatra@gmail.com', '2025-08-31 12:12:36'),
('4c0df9f0-c5a9-4c13-b08a-d175ffa95f75', 'rene@gmail.com', '2025-08-23 07:41:44'),
('558534c5-f83e-481b-884f-f6691b81ae33', 'santatra@gmail.com', '2025-08-31 07:08:29'),
('571d20a9-86aa-41b2-9074-3e0d34a33191', 'valentinmagde@gmail.com', '2025-08-10 09:59:10'),
('5e097650-0262-4017-bd0c-0fa86f9191fe', 'rene@gmail.com', '2025-08-15 11:10:51'),
('5ec36266-fc90-4ec0-9847-b485a9bb2d33', 'rene@gmail.com', '2025-08-24 06:48:54'),
('60cd7132-9396-4a43-b269-9e6a9857edc3', 'santatra@gmail.com', '2025-09-11 17:26:04'),
('61489275-ca4d-4fcd-b550-0798dcf667bf', 'santatra@gmail.com', '2025-09-04 08:07:30'),
('64001a2f-977c-479a-99f8-301f9ccb9298', 'santatra@gmail.com', '2025-08-31 07:07:13'),
('6df418e0-2cdf-4dcd-8ce1-319b334fc44a', 'rene@gmail.com', '2025-08-18 11:23:36'),
('731923b9-dc7e-4192-a431-fa556ec117c0', 'rene@gmail.com', '2025-08-22 06:52:39'),
('75d60fb0-38ed-4466-ab11-eaf9c16e294f', 'santatra@gmail.com', '2025-09-08 09:45:05'),
('7663e756-a58e-4fa1-98fb-2cbf2776acb8', 'rene@gmail.com', '2025-08-17 10:48:52'),
('7864ff6e-4333-4972-b755-55b392f24ab1', 'santatra@gmail.com', '2025-09-11 06:34:00'),
('809b53a5-9afd-49a1-9c54-fad92090cf1f', 'valentinmagde@gmail.com', '2025-08-11 10:59:07'),
('80ea5930-35e0-4c06-9c4d-e63bdc117fe1', 'rene@gmail.com', '2025-08-10 10:36:37'),
('867287b0-899f-4fdd-9337-1df29b8e6a01', 'rene@gmail.com', '2025-08-10 11:07:53'),
('885d0d92-0311-4cf3-8f56-6ea018a84ca6', 'rene@gmail.com', '2025-08-21 11:30:50'),
('8a6393c8-663e-4116-bff9-65ab3ff32d9a', 'rene@gmail.com', '2025-08-30 09:25:20'),
('8a6d45d718f9506bde2a7cddad03f2251075e872b18210bc2ada44f2cde50e94d7b3472127e46611555faadc39a0f8b4f8245f00e0ffc95f58e776a9b45b5051', 'rene@gmail.com', '2025-08-10 10:49:47'),
('8a9207da-1959-4aa6-ae29-0445301a20af', 'santatra@gmail.com', '2025-09-08 09:21:54'),
('8b62ac6b-29a9-4697-82e2-2361a1d254ef', 'rene@gmail.com', '2025-08-10 10:34:52'),
('9329c16d-68d5-4b41-9346-9553c3d42659', 'rene@gmail.com', '2025-08-22 06:14:39'),
('94ddf92f-9e36-4ff3-90f4-5fc1f259632b', 'rene@gmail.com', '2025-08-16 10:03:10'),
('9cbf70a0-6a50-4498-ba9c-89acb830098e', 'rene@gmail.com', '2025-08-21 10:42:01'),
('a0ceaf1b-bd15-4d3d-b791-7565f3ea92e1', 'rene@gmail.com', '2025-08-28 10:37:11'),
('a49185f6-c41e-4786-8ada-7f66336462c2', 'santatra@gmail.com', '2025-09-07 08:23:52'),
('aac805e9-84d3-44f3-b4b4-bed339e167dd', 'rene@gmail.com', '2025-08-24 10:39:03'),
('af10deb3-a92d-4107-80c4-08f1650844f6', 'santatra@gmail.com', '2025-09-11 18:33:55'),
('b440fbc7-2ebf-449d-be23-e1937f92504f', 'santatra@gmail.com', '2025-09-04 09:31:51'),
('b641f5c6-21c8-48ea-9033-ac8375fe85df', 'rene@gmail.com', '2025-08-21 08:40:42'),
('ba8618e5-8895-4ae8-9138-8213a3ffe674', 'valentinmagde@gmail.com', '2025-08-10 10:19:58'),
('be98df6a-8251-47f1-828d-2f0909f39e45', 'rene@gmail.com', '2025-08-16 07:56:37'),
('c0a8fa04-9fd1-4ccd-ba8d-652119112e08', 'rene@gmail.com', '2025-08-17 09:39:37'),
('c68d33ea-c534-464b-969f-8b5900f1c7b3', 'rene@gmail.com', '2025-08-23 07:12:42'),
('cb5805b3-5ce5-4e30-9c35-72de45d4aa70', 'tojo@gmail.com', '2025-08-23 09:30:11'),
('cd9bdbc7-bdf2-403f-99c0-3b6f3b1d9959', 'rene@gmail.com', '2025-08-17 07:24:18'),
('cf821452-4f7c-47cd-b46f-2aea6b1b9fd3', 'valentinmagde@gmail.com', '2025-08-11 10:59:54'),
('d54dabbf6b471ac5ff37a5b0141c4310327bd28ab2bb16789c7cb577d02c165161e17c76d328bd98c2d9646fa6db273c1b8d8d553c5347176f7020e9b3ddcaab', 'rene@gmail.com', '2025-08-14 22:02:43'),
('d695766b-ff4d-48d6-a3f1-60b4a21ccdf1', 'rene@gmail.com', '2025-08-10 11:05:15'),
('dbc72d1c-abb6-465f-af55-4cd331f5f847', 'rene@gmail.com', '2025-08-21 08:05:14'),
('dff8cc18-d1ca-4822-ae43-12c59ae81987', 'rene@gmail.com', '2025-08-28 08:01:29'),
('e0080c9f-8357-47ef-bd12-d4146e183f51', 'rene@gmail.com', '2025-08-16 12:23:21'),
('e1dd5c85-d1ce-496e-8666-93ce12323ac5', 'rene@gmail.com', '2025-08-29 07:12:12'),
('e7458cbe4adf6f4028c892f934465bf4e9138984f65f6df8eb53bef686fd483370e42fdee00e70bd1af5003f6c028869f66e1ab092fecf2f845aa0e713dc1479', 'rene@gmail.com', '2025-08-09 09:36:03'),
('e808c1191a1aeae9a89e24f23764844cb829f410c5bcb4ede2a10ace5766565afd5072d6148836da06433870c0dacc71cb485c1c5dac119906d8b376df19ed4a', 'rene@gmail.com', '2025-08-09 11:37:17'),
('ec5e0293-6ab0-4d04-b865-e759115a85c2', 'rene@gmail.com', '2025-08-23 09:31:05'),
('ef601e3f-8ae6-48fc-abb6-89e7375495b6', 'santatra@gmail.com', '2025-09-11 17:52:30'),
('f1a30243-1ad1-461d-a545-0bd6be41ab8b', 'rene@gmail.com', '2025-08-10 11:47:03'),
('f382bd94-c6a8-4363-8f3b-776862de59c1', 'rene@gmail.com', '2025-08-20 19:32:27'),
('f700a981-4b89-47b9-bd40-8da07766a7b8', 'rene@gmail.com', '2025-08-10 10:52:59'),
('f85264ae-9cf4-476b-8553-3781df976369', 'rene@gmail.com', '2025-08-14 06:46:09');

-- --------------------------------------------------------

--
-- Structure de la table `survey`
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `survey`
--

INSERT INTO `survey` (`id`, `surveyor_id`, `current_step`, `status_id`, `claim_number`) VALUES
(1, 5, 'step_3', 0, 'M0119923'),
(4, 5, 'step_3', 0, 'M0119925'),
(5, 5, 'step_1', 0, 'M0119926'),
(6, 5, 'step_1', 0, 'M0119927'),
(7, 5, 'step_1', 0, 'M0119928'),
(8, 5, 'step_1', 0, 'M0119929'),
(9, 5, 'step_1', 0, 'M0119930'),
(10, 5, 'step_1', 0, 'M0119931'),
(11, 5, 'step_1', 0, 'M0119932'),
(12, 5, 'step_1', 0, 'M0119933'),
(13, 5, 'step_1', 0, 'M0119934'),
(14, 5, 'step_1', 0, 'M0119935'),
(15, 5, 'step_1', 0, 'M0119936'),
(16, 1, 'step_1', 0, 'M0119925'),
(17, 0, 'step_1', 0, 'M0119921'),
(18, 5, 'step_1', 0, 'M0119920'),
(19, 5, 'step_1', 0, 'M0119919');

-- --------------------------------------------------------

--
-- Structure de la table `survey_information`
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `survey_information`
--

INSERT INTO `survey_information` (`id`, `verification_id`, `garage`, `garage_address`, `garage_contact_number`, `eor_value`, `invoice_number`, `survey_type`, `date_of_survey`, `time_of_survey`, `pre_accident_valeur`, `showroom_price`, `wrech_value`, `excess_applicable`) VALUES
(1, 1, 'Garage ABC', '123, Rue du Test, Quatre Bornes', '52521212', 105000, 'INV-2024-0001', 'Initial', '2025-07-17', '10:30:00', 150000, 170000, 30000, 5000),
(2, 4, 'Garage TE', 'Port Louis', '543729836', 105082, 'INV-2024-0002', 'Initial', '2025-07-17', '10:30:00', 192777, 170000, 328733, 5000),
(3, 4, 'Garage T', 'Quatre Bornes', '25327638', 250000, 'INV-2025-003', 'Survey with repairs', '2025-08-07', '10:30:00', 300000, 325000, 50000, 10000),
(4, 6, 'Garage T', 'Quatre bornes', '668623', 250000, 'INV-2025-003', 'Survey with repairs', '2025-08-07', '10:30:00', 300000, 325000, 50000, 10000);

-- --------------------------------------------------------

--
-- Structure de la table `vehicle_information`
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
  `chasisi_no` varchar(250) DEFAULT NULL,
  `vehicle_no` varchar(45) DEFAULT NULL,
  `color` varchar(45) DEFAULT NULL,
  `odometer_reading` int DEFAULT NULL,
  `is_the_vehicle_total_loss` tinyint DEFAULT NULL,
  `condition_of_vehicle` enum('good','medium') DEFAULT NULL,
  `place_of_survey` varchar(150) DEFAULT NULL,
  `point_of_impact` text,
  PRIMARY KEY (`id`),
  KEY `fk_vehicle_information_verification1_idx` (`verification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `vehicle_information`
--

INSERT INTO `vehicle_information` (`id`, `verification_id`, `make`, `model`, `cc`, `fuel_type`, `transmission`, `engime_no`, `chasisi_no`, `vehicle_no`, `color`, `odometer_reading`, `is_the_vehicle_total_loss`, `condition_of_vehicle`, `place_of_survey`, `point_of_impact`) VALUES
(1, 1, 'Toyota', 'Corolla', 1500, 'Petrol', 'Automatic', 'ENG123456789', 'CHS987654321', 'ABC-123', 'Red', 72000, 0, 'good', 'Garage ABC, Quatre Bornes', 'Front bumper'),
(5, 17, 'Mazda', 'BT50', 1200, 'Petrol', 'Manuel', '036 NI 09', 'CHS987654321', '626 GT 23', 'Blue', 2799, 0, 'good', 'QB', 'FrontBumper'),
(6, 4, 'Hyundai', 'i30', 77233, 'Petrol', 'Manuel', '036 NI 09', 'CHS987632', '787273 TG 09', 'Green', 2372873, 0, 'good', 'Port Louis', 'Bumper'),
(7, 6, 'Wolkswagen', 'Golf', 77233, 'Petrol', 'Manuel', '036 NI 09', 'CHS987632', '787273 TG 09', 'Green', 2372873, 0, 'good', 'Port Louis', 'Bumper');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `additional_labour_detail`
--
ALTER TABLE `additional_labour_detail`
  ADD CONSTRAINT `fk_additional_labour_detail_estimate_of_repair1` FOREIGN KEY (`estimate_of_repair_id`) REFERENCES `estimate_of_repair` (`id`);

--
-- Contraintes pour la table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `fk_documents_survey_information1` FOREIGN KEY (`survey_information_id`) REFERENCES `survey_information` (`id`);

--
-- Contraintes pour la table `estimate_of_repair`
--
ALTER TABLE `estimate_of_repair`
  ADD CONSTRAINT `fk_estimate_of_repair_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);

--
-- Contraintes pour la table `labour_detail`
--
ALTER TABLE `labour_detail`
  ADD CONSTRAINT `fk_labour_detail_part_detail1` FOREIGN KEY (`part_detail_id`) REFERENCES `part_detail` (`id`);

--
-- Contraintes pour la table `part_detail`
--
ALTER TABLE `part_detail`
  ADD CONSTRAINT `fk_part_detail_estimate_of_repair1` FOREIGN KEY (`estimate_of_repair_id`) REFERENCES `estimate_of_repair` (`id`);

--
-- Contraintes pour la table `picture_of_damage_car`
--
ALTER TABLE `picture_of_damage_car`
  ADD CONSTRAINT `fk_picture_of_domage_car_survey_information1` FOREIGN KEY (`survey_information_id`) REFERENCES `survey_information` (`id`);

--
-- Contraintes pour la table `survey_information`
--
ALTER TABLE `survey_information`
  ADD CONSTRAINT `fk_survey_information_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);

--
-- Contraintes pour la table `vehicle_information`
--
ALTER TABLE `vehicle_information`
  ADD CONSTRAINT `fk_vehicle_information_verification1` FOREIGN KEY (`verification_id`) REFERENCES `survey` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
