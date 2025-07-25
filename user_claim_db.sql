-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 25, 2025 at 07:57 AM
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

    -- Vérifie si l'utilisateur existe
    SELECT COUNT(*) INTO v_exists
    FROM user_claim_db.account_informations
    WHERE email_address = p_email_address;

    IF v_exists = 0 THEN
        SELECT 'Email introuvable.' AS message;
    ELSE
        -- Retourne l'utilisateur concerné
        SELECT *
        FROM user_claim_db.account_informations
        WHERE email_address = p_email_address;
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

    -- Set default values with validation
    SET p_email = IFNULL(p_email, '');
    SET p_status = IFNULL(p_status, '');
    SET p_search_name = IFNULL(p_search_name, '');
    SET p_sort_by = IFNULL(p_sort_by, 'date');
    SET p_page = GREATEST(IFNULL(p_page, 1), 1);
    SET p_page_size = IFNULL(p_page_size, 10);
    SET p_search_num = IFNULL(p_search_num, '');
    SET p_search_reg_num = IFNULL(p_search_reg_num, '');
    SET p_search_phone = IFNULL(p_search_phone, '');

    -- Validate email
    IF p_email = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''email est un paramètre obligatoire et ne peut pas être vide.';
    END IF;

    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM account_informations WHERE email_address = p_email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucun utilisateur trouvé avec cet email.';
    END IF;

    -- Initialize WHERE clause
    SET v_where = ' WHERE 1=1 ';

    -- Apply dynamic filters
    IF p_status <> '' THEN
        SET v_where = CONCAT(v_where, ' AND ST.status_name = ', QUOTE(p_status));
    END IF;
    IF p_search_name <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.name LIKE ''%', p_search_name, '%''');
    END IF;
    IF p_search_num <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.number LIKE ''%', p_search_num, '%''');
    END IF;
    IF p_search_reg_num <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.registration_number LIKE ''%', p_search_reg_num, '%''');
    END IF;
    IF p_search_phone <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.phone LIKE ''%', p_search_phone, '%''');
    END IF;

    -- Filter by user (email)
    SET v_where = CONCAT(v_where, ' AND ACI.email_address = ', QUOTE(p_email));

    -- Sorting logic
    IF p_sort_by = 'status' THEN
        SET v_order_by = ' ORDER BY ST.status_name ASC';
    ELSEIF p_sort_by = 'received_date' THEN
        SET v_order_by = ' ORDER BY CL.received_date DESC';
    ELSE
        SET v_order_by = ' ORDER BY CL.ageing DESC';
    END IF;

    -- Calculate offset
    SET v_offset = (p_page - 1) * p_page_size;

    -- Construct the query
    SET v_sql = CONCAT('
        SELECT
            CL.received_date,
            CL.number,
            CL.name,
            CL.registration_number,
            CL.ageing,
            CL.phone,
            ST.status_name
        FROM claims CL
        INNER JOIN assignment A ON CL.number = A.claims_number
        INNER JOIN users US ON US.id = A.users_id
        INNER JOIN account_informations ACI ON ACI.users_id = US.id
        INNER JOIN status ST ON A.status_id = ST.id
        ', v_where, v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);

    -- Execute the query
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `GetListByUserPag`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetListByUserPag` (IN `p_email` VARCHAR(255), IN `p_status` VARCHAR(255), IN `p_search_name` VARCHAR(255), IN `p_sort_by` VARCHAR(50), IN `p_page` INT, IN `p_page_size` INT, IN `p_search_num` VARCHAR(255), IN `p_search_reg_num` VARCHAR(255), IN `p_search_phone` VARCHAR(255))   BEGIN
    DECLARE v_where TEXT;
    DECLARE v_order_by TEXT;
    DECLARE v_offset INT;
    DECLARE v_sql TEXT;
    DECLARE v_sql_count TEXT;
    DECLARE v_total INT DEFAULT 0;

    -- Set default values
    SET p_email = IFNULL(p_email, '');
    SET p_status = IFNULL(p_status, '');
    SET p_search_name = IFNULL(p_search_name, '');
    SET p_sort_by = IFNULL(p_sort_by, 'date_DESC'); -- Valeur par défaut
    SET p_page = GREATEST(IFNULL(p_page, 1), 1);
    SET p_page_size = IFNULL(p_page_size, 10);
    SET p_search_num = IFNULL(p_search_num, '');
    SET p_search_reg_num = IFNULL(p_search_reg_num, '');
    SET p_search_phone = IFNULL(p_search_phone, '');

    -- Validation de l'email
    IF p_email = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''email est obligatoire.';
    END IF;

    -- Vérifier si l'utilisateur existe
    IF NOT EXISTS (
        SELECT 1 FROM account_informations WHERE email_address = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Utilisateur introuvable.';
    END IF;

    -- Construction du WHERE dynamique
    SET v_where = ' WHERE 1=1';

    IF p_status <> '' THEN
        SET v_where = CONCAT(v_where, ' AND ST.status_name = ', QUOTE(p_status));
    END IF;
    IF p_search_name <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.name LIKE ''%', p_search_name, '%''');
    END IF;
    IF p_search_num <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.number LIKE ''%', p_search_num, '%''');
    END IF;
    IF p_search_reg_num <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.registration_number LIKE ''%', p_search_reg_num, '%''');
    END IF;
    IF p_search_phone <> '' THEN
        SET v_where = CONCAT(v_where, ' AND CL.phone LIKE ''%', p_search_phone, '%''');
    END IF;

    SET v_where = CONCAT(v_where, ' AND ACI.email_address = ', QUOTE(p_email));

    -- Définir l'ordre de tri basé sur p_sort_by
    IF p_sort_by = 'date_ASC' THEN
        SET v_order_by = ' ORDER BY CL.received_date ASC';
    ELSEIF p_sort_by = 'date_DESC' THEN
        SET v_order_by = ' ORDER BY CL.received_date DESC';
    ELSEIF p_sort_by = 'ageing_ASC' THEN
        SET v_order_by = ' ORDER BY CL.ageing ASC';
    ELSEIF p_sort_by = 'ageing_DESC' THEN
        SET v_order_by = ' ORDER BY CL.ageing DESC';
    ELSE
        SET v_order_by = ' ORDER BY CL.received_date DESC'; -- tri par défaut
    END IF;

    -- Calcul du décalage
    SET v_offset = (p_page - 1) * p_page_size;

    -- Construction et exécution du SQL de comptage
    SET v_sql_count = CONCAT('
        SELECT COUNT(*) INTO @v_total
        FROM claims CL
        INNER JOIN assignment A ON CL.number = A.claims_number
        INNER JOIN users US ON US.id = A.users_id
        INNER JOIN account_informations ACI ON ACI.users_id = US.id
        INNER JOIN status ST ON A.status_id = ST.id
        ', v_where);

    SET @v_total = 0;
    SET @stmt = v_sql_count;
    PREPARE stmt_count FROM @stmt;
    EXECUTE stmt_count;
    DEALLOCATE PREPARE stmt_count;

    SELECT @v_total INTO v_total;

    -- Construction de la requête principale avec pagination
    SET v_sql = CONCAT('
        SELECT
            CL.received_date,
            CL.number,
            CL.name,
            CL.registration_number,
            CL.ageing,
            CL.phone,
            ST.status_name
        FROM claims CL
        INNER JOIN assignment A ON CL.number = A.claims_number
        INNER JOIN users US ON US.id = A.users_id
        INNER JOIN account_informations ACI ON ACI.users_id = US.id
        INNER JOIN status ST ON A.status_id = ST.id
        ', v_where, v_order_by, '
        LIMIT ', v_offset, ', ', p_page_size);

    -- Exécution de la requête principale
    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Résultat de pagination
    SELECT
        v_total AS total_claims,
        CEIL(v_total / p_page_size) AS total_pages,
        p_page AS current_page,
        GREATEST(p_page - 1, 1) AS previous_page,
        LEAST(p_page + 1, CEIL(v_total / p_page_size)) AS next_page,
        p_page_size AS page_size;
END$$

DROP PROCEDURE IF EXISTS `GetMethodCommunication`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMethodCommunication` ()  DETERMINISTIC BEGIN
    SELECT
       CM.*
    FROM user_claim_db.communication_methods CM;
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

DROP PROCEDURE IF EXISTS `GetUserClaimStats`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserClaimStats` (IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_total_claims INT DEFAULT 0;
    DECLARE v_new_claims INT DEFAULT 0;
    DECLARE v_queries_claims INT DEFAULT 0;
    DECLARE v_ageing_claims INT DEFAULT 0;

    -- Vérifier l’email
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''email est un paramètre obligatoire.';
    END IF;

    -- Vérifier si l'utilisateur existe
    IF NOT EXISTS (
        SELECT 1 FROM account_informations WHERE email_address = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucun utilisateur trouvé avec cet email.';
    END IF;

    -- received
    SELECT COUNT(*) INTO v_total_claims
    FROM claims CL
    INNER JOIN assignment A ON A.claims_number = CL.number
    INNER JOIN users U ON A.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    WHERE AI.email_address = p_email;

    -- Claims avec status = 'New'
    SELECT COUNT(*) INTO v_new_claims
    FROM claims CL
    INNER JOIN assignment A ON A.claims_number = CL.number
    INNER JOIN users U ON A.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    INNER JOIN status ST ON ST.id = A.status_id
    WHERE AI.email_address = p_email AND ST.status_name = 'New';

    -- Claims avec status = 'Queries'
    SELECT COUNT(*) INTO v_queries_claims
    FROM claims CL
    INNER JOIN assignment A ON A.claims_number = CL.number
    INNER JOIN users U ON A.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    INNER JOIN status ST ON ST.id = A.status_id
    WHERE AI.email_address = p_email AND ST.status_name = 'Queries';

    -- About to breach
    SELECT COUNT(*) INTO v_ageing_claims
    FROM claims CL
    INNER JOIN assignment A ON A.claims_number = CL.number
    INNER JOIN users U ON A.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    WHERE AI.email_address = p_email AND CL.ageing >= 48;

    -- Retourner les résultats sous forme d'une seule ligne
    SELECT
        v_total_claims AS received,
        v_new_claims AS new,
        v_ageing_claims AS about_to_breach,
        v_queries_claims AS queries;
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
        ASG.updated_at AS administrative_updated_at,

        GROUP_CONCAT(CM.method_name ORDER BY CM.method_name SEPARATOR ', ') AS communication_methods

    FROM user_claim_db.users U
    LEFT JOIN user_claim_db.account_informations AI
        ON U.id = AI.users_id
    LEFT JOIN user_claim_db.financial_informations FI
        ON U.id = FI.users_id
    LEFT JOIN user_claim_db.administrative_settings ASG
        ON U.id = ASG.users_id
    LEFT JOIN user_claim_db.admin_settings_communications ASCM
        ON ASG.id = ASCM.admin_setting_id
    LEFT JOIN user_claim_db.communication_methods CM
        ON ASCM.method_id = CM.id
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

DROP PROCEDURE IF EXISTS `InsertFullUserFromJSON`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertFullUserFromJSON` (IN `p_json_data` JSON)   BEGIN
    DECLARE v_users_id INT;

    -- 1. Insert into users
    INSERT INTO users(created_at, updated_at)
    VALUES (NOW(), NOW());

    SET v_users_id = LAST_INSERT_ID();

    -- 2. Insert into account_information
    INSERT INTO account_informations (
        users_id, business_name, business_registration_number,
        business_address, city, postal_code, phone_number,
        email_address, password, website, backup_email
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.businessName')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.businessRegistrationNumber')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.businessAddress')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.city')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.postalCode')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.phoneNumber')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.emailAddress')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.password')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.website')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.accountInformation.backupEmail'))
    );

     -- 3. Insert into financial_informations
    INSERT INTO financial_informations (
        users_id, vat_number, tax_identification_number,
        bank_name, bank_account_number, swift_code
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.financialInformation.vatNumber')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.financialInformation.taxIdentificationNumber')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.financialInformation.bankName')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.financialInformation.bankAccountNumber')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.financialInformation.swiftCode'))
    );


    -- 4. Insert into administrative_settings
    INSERT INTO administrative_settings (
        users_id, primary_contact_name, primary_contact_post, notification
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.administrativeSettings.primaryContactName')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.administrativeSettings.primaryContactPost')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.administrativeSettings.notification'))
    );

    -- 5. Insert into user_roles
    INSERT INTO user_roles (
        users_id, roles_id, assigned_at, is_active
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.rolesId')),
        NOW(),
        1
    );
    
    SELECT v_users_id AS user_id;
END$$

DROP PROCEDURE IF EXISTS `InsertUsers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUsers` (IN `p_business_name` VARCHAR(255), IN `p_business_registration_number` VARCHAR(100), IN `p_business_address` TEXT, IN `p_city` VARCHAR(100), IN `p_postal_code` VARCHAR(20), IN `p_phone_number` VARCHAR(30), IN `p_email_address` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_website` VARCHAR(255), IN `p_backup_email` VARCHAR(255))   BEGIN
    DECLARE v_verification_id INT;

    -- Insertion dans users
    INSERT INTO users(created_at, updated_at)
    VALUES (NOW(), NOW());

    -- Récupérer l'id inséré
    SET v_verification_id = LAST_INSERT_ID();

    -- Insertion dans account_information
    INSERT INTO account_informations (
        users_id,
        business_name,
        business_registration_number,
        business_address,
        city,
        postal_code,
        phone_number,
        email_address,
        password,
        website,
        backup_email
    )
    VALUES (
        v_verification_id,
        p_business_name,
        p_business_registration_number,
        p_business_address,
        p_city,
        p_postal_code,
        p_phone_number,
        p_email_address,
        p_password,
        p_website,
        p_backup_email
    );
END$$

DROP PROCEDURE IF EXISTS `UpdateAdminSettings`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAdminSettings` (IN `p_email_address` VARCHAR(255), IN `p_primary_contact_name` VARCHAR(100), IN `p_primary_contact_post` VARCHAR(100), IN `p_notification` BOOLEAN, IN `p_method_names` TEXT)   BEGIN
    DECLARE v_users_id INT;
    DECLARE v_admin_setting_id INT;
    DECLARE v_method_name VARCHAR(255);
    DECLARE v_pos INT DEFAULT 0;
    DECLARE v_next_pos INT DEFAULT 0;
    DECLARE v_len INT;
   
    -- Récupérer le users_id
    SELECT users_id INTO v_users_id
    FROM user_claim_db.account_informations
    WHERE email_address = p_email_address
    LIMIT 1;

    IF v_users_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email introuvable.';
    END IF;

    -- Récupérer l'admin_setting_id
    SELECT id INTO v_admin_setting_id
    FROM user_claim_db.administrative_settings
    WHERE users_id = v_users_id
    LIMIT 1;

    IF v_admin_setting_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Paramètres administratifs introuvables.';
    END IF;

    -- Mise à jour administrative_settings
    UPDATE user_claim_db.administrative_settings
    SET primary_contact_name = p_primary_contact_name,
        primary_contact_post = p_primary_contact_post,
        notification = p_notification,
        updated_at = NOW()
    WHERE users_id = v_users_id;

    -- Suppression des anciennes méthodes
    DELETE FROM user_claim_db.admin_settings_communications
    WHERE admin_setting_id = v_admin_setting_id;

    -- Boucle d'insertion des nouvelles méthodes
    SET v_len = CHAR_LENGTH(p_method_names);
    WHILE v_pos < v_len DO
        SET v_next_pos = LOCATE(',', p_method_names, v_pos + 1);
        IF v_next_pos = 0 THEN
            SET v_next_pos = v_len + 1;
        END IF;

        SET v_method_name = TRIM(SUBSTRING(p_method_names, v_pos + 1, v_next_pos - v_pos - 1));

        IF v_method_name != '' THEN
            INSERT INTO user_claim_db.admin_settings_communications (admin_setting_id, method_id)
            SELECT v_admin_setting_id, id
            FROM user_claim_db.communication_methods
            WHERE method_name = v_method_name;
        END IF;

        SET v_pos = v_next_pos;
    END WHILE;

    SELECT 'Mise à jour réussie' AS message;

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

DROP PROCEDURE IF EXISTS `UpdateSecuritySetting`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSecuritySetting` (IN `p_email_address` VARCHAR(100), IN `p_new_password` VARCHAR(255), IN `p_new_backup_email` VARCHAR(255))  DETERMINISTIC BEGIN
    DECLARE v_rows_updated INT DEFAULT 0;

    -- Mise à jour du mot de passe si fourni
    IF p_new_password IS NOT NULL AND p_new_password != '' THEN
        UPDATE user_claim_db.account_informations
        SET password = p_new_password
        WHERE email_address = p_email_address;
        
        SET v_rows_updated = v_rows_updated + ROW_COUNT();
    END IF;

    -- Mise à jour du backup email si fourni
    IF p_new_backup_email IS NOT NULL AND p_new_backup_email != '' THEN
        UPDATE user_claim_db.account_informations
        SET backup_email = p_new_backup_email
        WHERE email_address = p_email_address;

        SET v_rows_updated = v_rows_updated + ROW_COUNT();
    END IF;

    -- Vérification si au moins une mise à jour a eu lieu
    IF v_rows_updated = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aucune mise à jour effectuée. Paramètres vides ou email introuvable.';
    ELSE
        SELECT CONCAT('Mise à jour effectuée sur ', v_rows_updated, ' champ(s).') AS message;
    END IF;
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
  `users_id` int DEFAULT NULL,
  `business_name` varchar(150) NOT NULL,
  `business_registration_number` varchar(150) NOT NULL,
  `business_address` varchar(250) NOT NULL,
  `city` varchar(45) NOT NULL,
  `postal_code` varchar(45) NOT NULL,
  `phone_number` varchar(100) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `password` varchar(250) NOT NULL,
  `website` varchar(150) DEFAULT NULL,
  `backup_email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_address_UNIQUE` (`email_address`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `account_informations`
--

INSERT INTO `account_informations` (`id`, `users_id`, `business_name`, `business_registration_number`, `business_address`, `city`, `postal_code`, `phone_number`, `email_address`, `password`, `website`, `backup_email`) VALUES
(1, 1, 'Brondon', '48 AG 23', 'Squard Orchard', 'Quatre Bornes', '7000', '56589857', 'tojo@gmail.com', '$2y$12$hfHzc6co/yGxOHAZ/S7Tqe1ST1FPJo7EY4M72kVEls5IKisjc8kDy', 'www.tojosoa.com', 'tojoRene@gmail.com'),
(2, 2, 'Christofer', '1 JN 24', 'La Louis', 'Quatre Bornes', '7120', '57896532', 'valentinmagde@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.rene.com', ''),
(3, 3, 'Kierra', '94 NOV 06', 'Moka', 'Saint Pierre', '7520', '54789512', 'rene@gmail.com', '$2y$12$xhQSKfQWXosSbZCgfA3uAO6zD4CopXh9HrglAgUJFyRJuKCESOaN2', 'www.raharison.com', ''),
(4, 4, 'Surveyor 2', 'Surveyor 2', 'addr Surveyor 2', 'Quatre bornes', '7200', '55678923', 'surveyor2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.surveyor.com', ''),
(5, 5, 'Surveyor 3', 'Surveyor 2', 'Addr Surveyor 2', 'Quatre Bornes', '7500', '55897899', 'surveyor3@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.surveyor3.com', ''),
(6, 6, 'Garage 1', 'Garage 1', 'Addr Garage 1', 'Quatre bornes', '7200', '45677444', 'garage2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.garage2.com', ''),
(7, 7, 'Spare Part 2', 'Spare Part 2', 'Addr Spare Part 2', 'Quatre bornes', '7200', '34667777', 'sparepart@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.sparepart2.com', ''),
(8, 11, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(10, 13, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin4444@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(12, 16, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin53@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(14, 18, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin5344@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(15, 19, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin22@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(17, 21, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin2002@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(19, 23, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin200222@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(21, 25, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'admin333@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(23, 27, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'raharisontojo@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com'),
(25, 29, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'raharisontojo4@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `administrative_settings`
--

DROP TABLE IF EXISTS `administrative_settings`;
CREATE TABLE IF NOT EXISTS `administrative_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `users_id` int DEFAULT NULL,
  `primary_contact_name` varchar(255) NOT NULL,
  `primary_contact_post` varchar(150) NOT NULL,
  `notification` text NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_id_UNIQUE` (`users_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `administrative_settings`
--

INSERT INTO `administrative_settings` (`id`, `users_id`, `primary_contact_name`, `primary_contact_post`, `notification`, `updated_at`) VALUES
(1, 1, 'test 1', 'test 2', '0', '2025-07-23 07:54:02'),
(2, 16, '15', '222', 'Test notification', '2025-07-24 07:06:08'),
(3, 18, '15', '222', 'Test notification', '2025-07-24 07:09:24'),
(4, 19, '15', '222', 'Test notification', '2025-07-24 07:14:17'),
(5, 21, '15', '222', 'Test notification', '2025-07-24 07:16:34'),
(6, 23, '15', '222', 'Test notification', '2025-07-24 07:21:30'),
(7, 25, '15', '222', 'Test notification', '2025-07-24 08:12:03'),
(8, 27, '15', '222', 'Test notification', '2025-07-24 10:09:56'),
(9, 29, '15', '222', 'Test notification', '2025-07-24 10:15:55');

-- --------------------------------------------------------

--
-- Table structure for table `admin_settings_communications`
--

DROP TABLE IF EXISTS `admin_settings_communications`;
CREATE TABLE IF NOT EXISTS `admin_settings_communications` (
  `admin_setting_id` int NOT NULL,
  `method_id` int NOT NULL,
  PRIMARY KEY (`admin_setting_id`,`method_id`),
  KEY `IDX_42D45B4519883967` (`method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `admin_settings_communications`
--

INSERT INTO `admin_settings_communications` (`admin_setting_id`, `method_id`) VALUES
(1, 1),
(1, 2),
(1, 3);

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
('M0119923', 1, '2025-07-03 20:00:00', 'test', 1),
('M0119921', 6, '2025-07-03 20:00:00', 'Test affectation garage 1', 1);

-- --------------------------------------------------------

--
-- Table structure for table `blacklisted_token`
--

DROP TABLE IF EXISTS `blacklisted_token`;
CREATE TABLE IF NOT EXISTS `blacklisted_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text COLLATE utf8mb4_unicode_ci,
  `expires_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `blacklisted_token`
--

INSERT INTO `blacklisted_token` (`id`, `token`, `expires_at`) VALUES
(1, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3NTMxNzk5ODcsImV4cCI6MTc1MzE4NzE4Nywicm9sZXMiOlsic3BhcmVfcGFydCJdLCJ1c2VybmFtZSI6InJlbmVAZ21haWwuY29tIn0.thmAnfPaLoEJkZO5sm8F43NH-3e_ykjSc4S34atMh0OoeFMGZK8uNzV_koSAeNZy6FofBxTxgmRmGuKDLJOZ_oGt317irD7o0orNRDbVH3SjRkwqczaZxPrRiGfEcVp3RfVKM7aFKCO8lwJmePY-M4dRKvL5Z118sHQ5l0DTbTMX0BeRFzojO2IXJKEvvt3ynPeOpxpIW51vD8xxbP4UDUgNv84TvGxniQhgn9VpG_K8Hy_W2-o0JzaZ21iiJu4Qt7Ti3tSuexJRNAzd-AJliTKtItUFAJ8e4MMJIwi_HlcuEhiN7J76ytmSpTNnREcWupRpoGl7bzWQttin1zsZ0T389KNIscKWJfAER9n3qIeKi6p6DbQ3bRvL3Of8lg2C0qZshFYTiondrJwntCdMiBgbE8cd3lwmkCHxCPdiZUtJdb2ZI6VJLZzXdkdeh8HsqDqQFalaPnRovENLiM7xyVPXZ3hVEYnZ5NQrKhRL35NkdOcK9nQELhgYfMKwEnXXG2bRbDa2qB7kbJSIYcrg0OF_T_3wFvJWtix4N770vHHoH1LfOVVoxdCiSJZj0v315Rz_blWdHlhSSnDVTxWhhzsHZlSiVAvbGyOLBAqEZkqzHskOQyjVz8l4i6DgNoIRoQ0Z89povMkJvQdoY1IopmG4wjzwHzyc5G0-7hbdVlE', '2025-07-22 12:26:27'),
(2, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3NTMxODgwODAsImV4cCI6MTc1MzE5NTI4MCwicm9sZXMiOlsic3BhcmVfcGFydCJdLCJ1c2VybmFtZSI6InJlbmVAZ21haWwuY29tIn0.pDIonER3ELvjQ5MOcACefAjl0yV6rzmM1ypzxp971RTbjRl6rTCAXh_mjbhgWWX2u7cXjjGJEamKu2cXfKmnif1BizChjS7QzwM2NzDkIQusMwSq-sGsDGN9FB0e6FHOS35D-R-IymMAnwmwcF94i7dXw7kBj9Nhqvy0SCZBSpgIUWM1i3ArkI_c-frYLEsxQ3C-h_vxMox5rjBk5QDD8hsDqU51P1SwHWKIUz8G5FJL01iXhHQHjt8vKHNqupVArLL0QiIEGn2ZGSFSF82yRwJKNN96rLfsrX_efuL4WWwrk_Tq4Q2GnIJH4bdCRTFS8k_Q8eJt5seKTV-RxgkriedWdxgpVvqWmCwhhjvG8gcfTTfMbTdd_NaGLVfMBawj4HQFQiJP3YCduR68Nc5WyaKsCRFxmYFS0zss-8RDWUMH8aTTXzhZXEhe2RMYf0-ADRTWXYIHDsWtqqBZEV-tlc2JZyOXYnz7VqW_ROaNUN1JjxftX7SLH7xy0l_h-z3XIX9gTRJWG-BjmfhAXqrWyUJ5Qpp_K0w3CtKmtS86GNpUPefIEnCfxgRzBLWgnofq8yEB0ciNfGg7sU1kjJM_MHzj7yHPoBNe2pwmdx-_KTm_Nk-ijgoNWIwNDRlUgvTppErzaB9VFJs3VfkqYoKw4afNrmzgkBhR7Jm5iw2i0BE', '2025-07-22 14:41:20');

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `communication_methods`
--

INSERT INTO `communication_methods` (`id`, `method_code`, `method_name`, `description`, `updated_at`) VALUES
(1, 'email', 'Email', 'Communication email', '2025-07-22 06:25:59'),
(2, 'sms', 'SMS', 'Communication sms', '2025-07-22 06:25:59'),
(3, 'portal', 'Portal', 'Communication portal', '2025-07-22 06:26:49');

-- --------------------------------------------------------

--
-- Table structure for table `doctrine_migration_versions`
--

DROP TABLE IF EXISTS `doctrine_migration_versions`;
CREATE TABLE IF NOT EXISTS `doctrine_migration_versions` (
  `version` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `financial_informations`
--

INSERT INTO `financial_informations` (`id`, `users_id`, `vat_number`, `tax_identification_number`, `bank_name`, `bank_account_number`, `swift_code`) VALUES
(1, 16, '15', '222', 'mcb', 1111111111111, 'V446'),
(2, 18, '15', '222', 'mcb', 1111111111111, 'V446'),
(3, 19, '15', '222', 'mcb', 1111111111111, 'V446'),
(4, 21, '15', '222', 'mcb', 1111111111111, 'V446'),
(5, 23, '15', '222', 'mcb', 1111111111111, 'V446'),
(6, 25, '15', '222', 'mcb', 1111111111111, 'V446'),
(7, 27, '15', '222', 'mcb', 1111111111111, 'V446'),
(8, 29, '15', '222', 'mcb', 1111111111111, 'V446');

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
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3;

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
(7, '2025-06-26 22:53:30', '2025-06-26 22:53:30'),
(8, '2025-07-23 09:54:18', '2025-07-23 09:54:18'),
(9, '2025-07-23 12:35:42', '2025-07-23 12:35:42'),
(10, '2025-07-23 12:45:03', '2025-07-23 12:45:03'),
(11, '2025-07-23 12:47:26', '2025-07-23 12:47:26'),
(12, '2025-07-24 07:00:16', '2025-07-24 07:00:16'),
(13, '2025-07-24 07:01:08', '2025-07-24 07:01:08'),
(14, '2025-07-24 07:01:27', '2025-07-24 07:01:27'),
(15, '2025-07-24 07:05:50', '2025-07-24 07:05:50'),
(16, '2025-07-24 07:06:08', '2025-07-24 07:06:08'),
(17, '2025-07-24 07:09:10', '2025-07-24 07:09:10'),
(18, '2025-07-24 07:09:24', '2025-07-24 07:09:24'),
(19, '2025-07-24 07:14:17', '2025-07-24 07:14:17'),
(20, '2025-07-24 07:15:16', '2025-07-24 07:15:16'),
(21, '2025-07-24 07:16:34', '2025-07-24 07:16:34'),
(22, '2025-07-24 07:21:18', '2025-07-24 07:21:18'),
(23, '2025-07-24 07:21:30', '2025-07-24 07:21:30'),
(24, '2025-07-24 08:11:47', '2025-07-24 08:11:47'),
(25, '2025-07-24 08:12:03', '2025-07-24 08:12:03'),
(26, '2025-07-24 10:09:31', '2025-07-24 10:09:31'),
(27, '2025-07-24 10:09:56', '2025-07-24 10:09:56'),
(28, '2025-07-24 10:15:38', '2025-07-24 10:15:38'),
(29, '2025-07-24 10:15:55', '2025-07-24 10:15:55');

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
(7, 3, '2025-06-26 22:56:16', 1),
(18, 1, '2025-07-24 07:09:24', 1),
(19, 1, '2025-07-24 07:14:17', 1),
(21, 1, '2025-07-24 07:16:34', 1),
(23, 1, '2025-07-24 07:21:30', 1),
(25, 1, '2025-07-24 08:12:03', 1),
(27, 1, '2025-07-24 10:09:56', 1),
(29, 1, '2025-07-24 10:15:55', 1);

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
  ADD CONSTRAINT `FK_42D45B45260B1BF7` FOREIGN KEY (`admin_setting_id`) REFERENCES `administrative_settings` (`id`),
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
