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
-- Base de données : `user_claim_db`
--

DELIMITER $$
--
-- Procédures
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
    DECLARE v_status_filter TEXT;

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

    IF p_status = 'Breach' THEN
    SET v_where = CONCAT(v_where, ' AND CL.ageing >= 48 AND ST.status_name = ''new''');
    ELSEIF p_status <> '' THEN
        SET v_status_filter = CONCAT('''', REPLACE(p_status, ',', ''','''), '''');
        SET v_where = CONCAT(v_where, ' AND ST.status_name IN (', v_status_filter, ')');
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
    IF p_sort_by = 'received_date-asc' THEN
        SET v_order_by = ' ORDER BY CL.received_date ASC';
    ELSEIF p_sort_by = 'received_date-desc' THEN
        SET v_order_by = ' ORDER BY CL.received_date DESC';
    ELSEIF p_sort_by = 'ageing-asc' THEN
        SET v_order_by = ' ORDER BY CL.ageing ASC';
    ELSEIF p_sort_by = 'ageing-desc' THEN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMethodCommunication` ()   BEGIN
    SELECT
       CM.*
    FROM user_claim_db.communication_methods CM;
END$$

DROP PROCEDURE IF EXISTS `GetPaymentDetailsByInvoice`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPaymentDetailsByInvoice` (IN `p_invoice_no` VARCHAR(100), IN `p_email` VARCHAR(100))   BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Vérifier que le paiement existe ET que l'email correspond
    SELECT COUNT(*) INTO v_exists
    FROM payment p
    INNER JOIN claims c ON c.number = p.claim_number
    INNER JOIN users u ON u.id = p.users_id
    INNER JOIN account_informations ai ON ai.users_id = u.id
    WHERE p.invoice_no = p_invoice_no
      AND ai.email_address = p_email;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Paiement introuvable ou email incorrect.';
    ELSE
        SELECT 
            p.invoice_no,
            st.status_name,
            p.invoice_date,
            p.claim_number,
            c.name AS client,
            ai.business_name AS attention,
            c.registration_number,
            p.claim_amount,
            p.vat,
            ROUND(p.claim_amount + (p.claim_amount * p.vat / 100), 2) AS total_amount
        FROM payment p
        INNER JOIN user_claim_db.status ST ON p.status_id = ST.id
        INNER JOIN claims c ON c.number = p.claim_number
        INNER JOIN users u ON u.id = p.users_id
        INNER JOIN account_informations ai ON ai.users_id = u.id
        WHERE p.invoice_no = p_invoice_no
          AND ai.email_address = p_email;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `GetPaymentListByUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPaymentListByUser` (IN `p_email` VARCHAR(255), IN `p_status` VARCHAR(255), IN `p_invoice_no` VARCHAR(100), IN `p_claim_number` VARCHAR(100), IN `p_sort_by` VARCHAR(50), IN `p_page` INT, IN `p_page_size` INT, IN `p_start_date` DATETIME, IN `p_end_date` DATETIME)   BEGIN
    DECLARE v_where TEXT;
    DECLARE v_order_by TEXT;
    DECLARE v_offset INT;
    DECLARE v_sql TEXT;
    DECLARE v_sql_count TEXT;
    DECLARE v_limit_clause TEXT;
    DECLARE v_total INT DEFAULT 0;

    -- Valeurs par défaut
    SET p_email = IFNULL(p_email, '');
    SET p_status = IFNULL(p_status, '');
    SET p_invoice_no = IFNULL(p_invoice_no, '');
    SET p_claim_number = IFNULL(p_claim_number, '');
    SET p_sort_by = IFNULL(p_sort_by, 'date_submitted-desc');
    SET p_page = GREATEST(IFNULL(p_page, 1), 1);
    SET p_page_size = IFNULL(p_page_size, 10);

    -- Vérification de l'e-mail
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

    -- Validation : Si une date est fournie, l'autre doit l'être aussi
    IF (p_start_date IS NOT NULL AND p_end_date IS NULL)
        OR (p_end_date IS NOT NULL AND p_start_date IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Les deux dates (date_debut et date_fin) doivent être renseignées ensemble.';
    END IF;

    -- WHERE dynamique
    SET v_where = ' WHERE 1=1';

    IF p_status <> '' THEN
        SET v_where = CONCAT(v_where, ' AND ST.status_name = ', QUOTE(p_status));
    END IF;

    IF p_invoice_no <> '' THEN
        SET v_where = CONCAT(v_where, ' AND P.invoice_no LIKE ''%', p_invoice_no, '%''');
    END IF;

    IF p_claim_number <> '' THEN
        SET v_where = CONCAT(v_where, ' AND P.claim_number LIKE ''%', p_claim_number, '%''');
    END IF;

    -- Filtre sur les dates si les deux sont renseignées
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND P.date_submitted BETWEEN ''', p_start_date, ''' AND ''', p_end_date, '''');
        SET v_limit_clause = ''; -- désactiver pagination
    ELSE
        SET v_offset = (p_page - 1) * p_page_size;
        SET v_limit_clause = CONCAT(' LIMIT ', v_offset, ', ', p_page_size);
    END IF;

    SET v_where = CONCAT(v_where, ' AND ACI.email_address = ', QUOTE(p_email));

    -- Tri
    IF p_sort_by = 'date_submitted-asc' THEN
        SET v_order_by = ' ORDER BY P.date_submitted ASC';
    ELSEIF p_sort_by = 'date_submitted-desc' THEN
        SET v_order_by = ' ORDER BY P.date_submitted DESC';
    ELSEIF p_sort_by = 'date_payment-asc' THEN
        SET v_order_by = ' ORDER BY P.date_payment ASC';
    ELSEIF p_sort_by = 'date_payment-desc' THEN
        SET v_order_by = ' ORDER BY P.date_payment DESC';
    ELSE
        SET v_order_by = ' ORDER BY P.date_submitted DESC';
    END IF;

    -- SQL de comptage
    SET v_sql_count = CONCAT('
        SELECT COUNT(*) INTO @v_total
        FROM payment P
        INNER JOIN users U ON P.users_id = U.id
        INNER JOIN account_informations ACI ON ACI.users_id = U.id
        INNER JOIN status ST ON ST.id = P.status_id
        ', v_where);

    SET @v_total = 0;
    SET @stmt = v_sql_count;
    PREPARE stmt_count FROM @stmt;
    EXECUTE stmt_count;
    DEALLOCATE PREPARE stmt_count;

    SELECT @v_total INTO v_total;

    -- Requête principale
    SET v_sql = CONCAT('
        SELECT
            P.invoice_no,
            P.date_submitted,
            P.date_payment,
            ST.status_name,
            P.claim_number,
            P.claim_amount
        FROM payment P
        INNER JOIN users U ON P.users_id = U.id
        INNER JOIN account_informations ACI ON ACI.users_id = U.id
        INNER JOIN status ST ON ST.id = P.status_id
        ', v_where, v_order_by, v_limit_clause);

    SET @sql = v_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Pagination
    SELECT
        v_total AS total_paiements,
        CEIL(v_total / p_page_size) AS total_pages,
        p_page AS current_page,
        GREATEST(p_page - 1, 1) AS previous_page,
        LEAST(p_page + 1, CEIL(v_total / p_page_size)) AS next_page,
        p_page_size AS page_size;
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

DROP PROCEDURE IF EXISTS `GetUserPaymentStats`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserPaymentStats` (IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_total_paiements INT DEFAULT 0;
    DECLARE v_under_review INT DEFAULT 0;
    DECLARE v_paid INT DEFAULT 0;
    DECLARE v_approved INT DEFAULT 0;

    -- Vérification de l’email
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

    -- Total des paiements
    SELECT COUNT(*) INTO v_total_paiements
    FROM payment P
    INNER JOIN users U ON P.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    WHERE AI.email_address = p_email;

    -- Paiements avec status = 'Under review'
    SELECT COUNT(*) INTO v_under_review
    FROM payment P
    INNER JOIN users U ON P.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    INNER JOIN status ST ON ST.id = P.status_id
    WHERE AI.email_address = p_email AND ST.status_name = 'Under review';

    -- Paiements avec status = 'Approved'
    SELECT COUNT(*) INTO v_approved
    FROM payment P
    INNER JOIN users U ON P.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    INNER JOIN status ST ON ST.id = P.status_id
    WHERE AI.email_address = p_email AND ST.status_name = 'Approved';

    -- Paiements avec status = 'Paid'
    SELECT COUNT(*) INTO v_paid
    FROM payment P
    INNER JOIN users U ON P.users_id = U.id
    INNER JOIN account_informations AI ON AI.users_id = U.id
    INNER JOIN status ST ON ST.id = P.status_id
    WHERE AI.email_address = p_email AND ST.status_name = 'Paid';

    -- Retourner les résultats sous forme d'une ligne
    SELECT
        v_total_paiements AS total,
        v_under_review AS under_review,
        v_approved AS approved,
        v_paid AS paid;
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

DROP PROCEDURE IF EXISTS `InsertUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUser` (IN `p_json_data` JSON)   BEGIN
    DECLARE v_users_id INT;

    -- 1. Insert into users
    INSERT INTO users(created_at, updated_at)
    VALUES (NOW(), NOW());

    SET v_users_id = LAST_INSERT_ID();

    -- 2. Insert into account_information
    INSERT INTO account_information (
        verification_id, business_name, business_registration_number,
        business_address, city, postal_code, phone_number,
        email_address, password, website, backup_email
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.business_name')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.business_registration_number')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.business_address')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.city')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.postal_code')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.phone_number')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.email_address')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.password')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.website')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.backup_email'))
    );

    -- 3. Insert into financial_informations
    INSERT INTO financial_informations (
        users_id, vat_number, tax_identification_number,
        bank_name, city, swift_code
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.vat_number')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.tax_identification_number')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.bank_name')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.bank_account_number')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.swift_code'))
    );

    -- 4. Insert into administrative_settings
    INSERT INTO administrative_settings (
        users_id, primary_contact_name, primary_contact_post, notification
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.primary_contact_name')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.primary_contact_post')),
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.notification'))
    );

    -- 5. Insert into user_roles
    INSERT INTO user_roles (
        users_id, roles_id, assigned_at, is_active
    ) VALUES (
        v_users_id,
        JSON_UNQUOTE(JSON_EXTRACT(p_json_data, '$.roles_id')),
        NOW(),
        1
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSecuritySetting` (IN `p_email_address` VARCHAR(100), IN `p_new_password` VARCHAR(100), IN `p_new_backup_email` VARCHAR(100))   BEGIN
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
-- Structure de la table `account_informations`
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `account_informations`
--

INSERT INTO `account_informations` (`id`, `users_id`, `business_name`, `business_registration_number`, `business_address`, `city`, `postal_code`, `phone_number`, `email_address`, `password`, `website`, `backup_email`) VALUES
(1, 1, 'Brondon', '48 AG 23', 'Squard Orchard', 'Quatre Bornes', '7000', '56589857', 'tojo@gmail.com', '$2y$12$DQcPA1dClkAMmVYnjFesKedCBkiLuZj7mD0gqgzegunGQ5X9/Rw16', 'www.test8.com', ''),
(2, 2, 'Christofer', '1 JN 24', 'La Louis', 'Quatre Bornes', '7120', '57896532', 'rene@gmail.com', '$2y$12$Wg3ISNFeWVw.yGV9u7EVtOpMCk7z64KZ9SpKZIgXaoeeuYZe8pbKC', 'www.rene.com', ''),
(3, 3, 'Kierra', '94 NOV 06', 'Moka', 'Saint Pierre', '7520', '54789512', 'raharison@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.raharison.com', ''),
(4, 4, 'Surveyor 2', 'Surveyor 2', 'addr Surveyor 2', 'Quatre bornes', '7200', '55678923', 'surveyor2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.surveyor.com', ''),
(5, 5, 'Surveyor 3', 'Surveyor 2', 'Addr Surveyor 2', 'Quatre Bornes', '7500', '55897899', 'santatra@gmail.com', '$2y$12$Wg3ISNFeWVw.yGV9u7EVtOpMCk7z64KZ9SpKZIgXaoeeuYZe8pbKC', 'www.surveyor3.com', ''),
(6, 6, 'Garage 1', 'Garage 1', 'Addr Garage 1', 'Quatre bornes', '7200', '45677444', 'garage2@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.garage2.com', ''),
(7, 7, 'Spare Part 2', 'Spare Part 2', 'Addr Spare Part 2', 'Quatre bornes', '7200', '34667777', 'sparepart@gmail.com', '$2y$12$nHmXmOQnSx4Nt0H7DX3Ye.OIa7BEjRz1Ez.gK3uxG8C1JwBBLmbCa', 'www.sparepart2.com', ''),
(8, 10, 'Miha', '67236', 'Qutre bornes', 'Quatre borne', '101', '3U873839', 'miha@gmail.com', '123456', 'miha@website.com', 'mia@gmail.com'),
(9, 11, 'Super admin', '123456789', '123 Rue Principale', 'Paris', '75001', '+33123456789', 'raharisontojo4@gmail.com', 'Tojo@1235', 'https://monentreprise.com', 'tt@gmail.com');

-- --------------------------------------------------------

--
-- Structure de la table `administrative_settings`
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `administrative_settings`
--

INSERT INTO `administrative_settings` (`id`, `users_id`, `primary_contact_name`, `primary_contact_post`, `notification`, `updated_at`) VALUES
(1, 1, 'rene', 'testpost', '0', '2025-07-23 07:43:44'),
(2, 11, '15', '222', 'Test notification', '2025-07-24 10:40:18');

-- --------------------------------------------------------

--
-- Structure de la table `admin_settings_communications`
--

DROP TABLE IF EXISTS `admin_settings_communications`;
CREATE TABLE IF NOT EXISTS `admin_settings_communications` (
  `admin_setting_id` int NOT NULL,
  `method_id` int NOT NULL,
  PRIMARY KEY (`admin_setting_id`,`method_id`),
  KEY `IDX_42D45B4519883967` (`method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `admin_settings_communications`
--

INSERT INTO `admin_settings_communications` (`admin_setting_id`, `method_id`) VALUES
(1, 1),
(1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `assignment`
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
-- Déchargement des données de la table `assignment`
--

INSERT INTO `assignment` (`claims_number`, `users_id`, `assignment_date`, `assignement_note`, `status_id`) VALUES
('M0119921', 1, '2025-07-04 11:03:40', NULL, 2),
('M0119923', 5, '2025-07-03 20:00:00', 'test', 4),
('M0119921', 6, '2025-07-03 20:00:00', 'Test affectation garage 1', 1),
('M0119925', 5, '2025-07-06 07:00:00', 'urgent', 3),
('M0119926', 5, '2025-07-07 06:30:00', 'à vérifier', 1),
('M0119927', 5, '2025-07-08 08:15:00', 'dommages mineurs', 2),
('M0119928', 5, '2025-07-09 05:45:00', 'prioritaire', 1),
('M0119929', 5, '2025-07-10 11:00:00', 'réclamation en attente', 2),
('M0119930', 5, '2025-07-11 10:30:00', 'à traiter rapidement', 1),
('M0119931', 5, '2025-07-12 12:10:00', 'sinistre confirmé', 1),
('M0119932', 5, '2025-07-13 07:20:00', 'visite sur site prévue', 2),
('M0119933', 5, '2025-07-14 06:00:00', 'urgence faible', 1),
('M0119934', 5, '2025-07-15 13:45:00', 'pièces manquantes', 1),
('M0119935', 5, '2025-07-16 11:14:57', 'test', 2),
('M0119936', 5, '2025-07-17 07:40:00', 'sinistre complet', 1),
('M0119937', 5, '2025-08-07 09:43:08', 'note', 3),
('M0119938', 5, '2025-08-07 09:43:29', 'note1', 4),
('M0119939', 5, '2025-08-07 09:45:20', 'note2', 9);

-- --------------------------------------------------------

--
-- Structure de la table `blacklisted_token`
--

DROP TABLE IF EXISTS `blacklisted_token`;
CREATE TABLE IF NOT EXISTS `blacklisted_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `expires_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blacklisted_token`
--

INSERT INTO `blacklisted_token` (`id`, `token`, `expires_at`) VALUES
(1, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3NTMyNTAwNjgsImV4cCI6MTc1MzI1NzI2OCwicm9sZXMiOlsiZ2FyYWdlIl0sInVzZXJuYW1lIjoicmVuZUBnbWFpbC5jb20ifQ.TtllsQbeQ4uM5cYIdoheYigVg9EZLjA4IBZ4wugl_wlmdq2G_4ZJ3xQvapFlfw70hVh3D1PNcgbGfSljjYh5mE3nfoBnPcF6qaz9Tj85LaRZTPAkbOXWLmeuJH6gzP1v-ouKEIeqOsNTqDliovVjrtArj2s7ZJSdAXhE4tHuZ0QXRFWVXEKCVcZ22609uzI1IBo1FGcsymik4rfLNstdFBpwR61V2mkWrBRpcafJyyXs0NrXPIlqFxU5IZJ8u88yG3vowhnEAVpjC3PM1rvR9X5Qd3AO8ymvzRWJ4To6RpGH2Ai3rNHuveiGC6t75DoH-7t5c7d-X5ItawJWpY1kbJNgNqZ32P-7YKViwFAoTUTbxi5ML0GCs-ym8VCghMBqxID91gtuYX6S9Dgmw3fbHHK2cZeUwaWJ17uNzu3qBWm0xBmksRgxwP8CEKIArw_JXL7GdQkLkqGOK0egRWXRbEmQkU8IcP1ZT0jqoVjEHvwKewU2GhVw_5UrOBe7QHAemFYzUYdurepzDXOSHAqZmBy_g18fueUe2w1OPpEImlhJQHso4iWpkMcZO-TzzRoS74BCQ_bqDhfxpkd8uLeTojad-hm70hpP5nMsgBxOfsdQOeimNeh5PI5Uo2EHHyPq32WiKEGXJjx_IA5UFvrp374KKjhA6Ipx7ca2rwJrnYY', '2025-07-23 07:54:28'),
(2, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3NTM5NDUwMzQsImV4cCI6MTc1NDAzMTQzNCwicm9sZXMiOlsic3VydmV5b3IiXSwidXNlcm5hbWUiOiJzYW50YXRyYUBnbWFpbC5jb20iLCJpZCI6NSwiYnVzaW5lc3NfbmFtZSI6IlN1cnZleW9yIDMifQ.O1D6iH0IneKhI5wzEcFSmEfMKDryJQxqh_IDtSJXzfMpOOhJM12ij39Tw1YenxN-sd2kt-FuBelu9HOJniTIKynzekn94GYjR9sWrVnlMMWnzdtpCybiUiaraJwZf-budZlm0cjgj_xJiaE5yrvAzyLrXYfcYljX1ITgzhR8mfpcA0dDsO6u8EtIaPNV55KRLrAsjwYGIxQUhh4da1sONyjTSG7MhM5mTK0BXiTsrWvaCdMBwyyYWvpMvV90htYo1RN8TAJwiwdWzbCgXH6DbuVmiO0Lb7e340tce3t-b286vC3bp9P4JHCWfMfBfP4p6rSOGeuMgyKsOG5bnnjeohzIi5dKc0fEXmdc-F4lEpr0XEgqvSEkFg8sNhQ33Pk7IUXhSuHF5JhROgIiPfEGFDfQcD1LmJfJFRw6WkW-ybsentaYRIbOdh1aSDxGwgrig6QwQmkoaHYOQ0NkutWsgjxLoHnrU1raXokGcltxhu2FaF0IrdkXffVJFo6BtlJfx31LTv2DrhDzijWBWx4klyjRMkgp7TAn305-RqhDpRMBFGqAN_q2sS2KnUeEm0ZawHxI3Fqe0adgjX30nAer6AW9-JosuyhO2oo2fUnwv4YVgH8AL4g-EDyLBmqsUiT3YlqIOWS9Z9v6Dd_m84UgozbIuiesjfDHJS7pVYT5JsY', '2025-08-01 06:57:14');

-- --------------------------------------------------------

--
-- Structure de la table `claims`
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `claims`
--

INSERT INTO `claims` (`id`, `received_date`, `number`, `name`, `registration_number`, `ageing`, `phone`, `affected`, `status_id`) VALUES
(1, '2025-06-29', 'M0119921', 'Brandon Philipps', '9559 AG 23', 120, '55487956', 1, 1),
(2, '2025-06-30', 'M0119922', 'Christofer Curtis', '1 JN 24', 96, '54789632', 0, 1),
(3, '2025-06-01', 'M0119923', 'Kierra', '95 ZN 15', 72, '58796301', 1, 4),
(4, '2025-07-02', 'M0119924', 'Test dev 1', '1525 ZN 45', 48, '48503895', 0, 1),
(6, '2025-07-05', 'M0119925', 'Amanda Vickers', '8596 XD 44', 60, '59203456', 1, 1),
(7, '2025-07-06', 'M0119926', 'Daniel Moore', '4412 BG 12', 36, '59216789', 0, 1),
(8, '2025-07-07', 'M0119927', 'Lucinda Evans', '7925 ZA 09', 15, '59984512', 1, 2),
(9, '2025-07-08', 'M0119928', 'Marcus Reed', '2233 BY 22', 90, '59321478', 1, 2),
(10, '2025-07-09', 'M0119929', 'Jasmine White', '6547 CG 88', 105, '59123658', 0, 1),
(11, '2025-07-10', 'M0119930', 'Nathan Scott', '8833 LM 01', 20, '59632145', 1, 2),
(12, '2025-07-11', 'M0119931', 'Sarah Foster', '1144 JN 99', 50, '59876543', 0, 1),
(13, '2025-07-12', 'M0119932', 'Tyler Brown', '4321 GT 76', 80, '59001234', 1, 1),
(14, '2025-07-13', 'M0119933', 'Emily Davis', '2312 QQ 56', 110, '59234567', 0, 2),
(15, '2025-07-14', 'M0119934', 'George Clark', '9988 RS 34', 65, '59432167', 1, 1),
(16, '2025-07-15', 'M0119935', 'Isabelle Turner', '7865 YT 90', 30, '59764321', 0, 2),
(17, '2025-07-16', 'M0119936', 'Liam Johnson', '3021 AZ 78', 25, '59112233', 1, 1),
(18, '2025-08-07', 'M0119937', 'Jean', '7387283 AN 52', 13, '3263723829', 1, 3),
(19, '2025-08-07', 'M0119938', 'Marie', '28938 IT 08', 11, '827323739', 1, 4),
(20, '2025-08-07', 'M0119939', 'Lulu', '893892 TF 03', 10, '8297379230', 1, 9);

-- --------------------------------------------------------

--
-- Structure de la table `communication_methods`
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
-- Déchargement des données de la table `communication_methods`
--

INSERT INTO `communication_methods` (`id`, `method_code`, `method_name`, `description`, `updated_at`) VALUES
(1, 'email', 'Email', 'gffyfyuf', '2025-07-21 11:47:01'),
(2, 'sms', 'SMS', 'ggygu', '2025-07-21 11:47:01'),
(3, 'portal', 'Portal', 'hhghgh', '2025-07-21 11:47:24');

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
-- Structure de la table `financial_informations`
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `financial_informations`
--

INSERT INTO `financial_informations` (`id`, `users_id`, `vat_number`, `tax_identification_number`, `bank_name`, `bank_account_number`, `swift_code`) VALUES
(1, 1, 'VAT0012345678', 'TIN4567890123', 'Global Bank PLC', 1234567890123456, 'GLBPPLM0123'),
(2, 11, '15', '222', 'mcb', 1111111111111, 'V446');

-- --------------------------------------------------------

--
-- Structure de la table `payment`
--

DROP TABLE IF EXISTS `payment`;
CREATE TABLE IF NOT EXISTS `payment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `date_submitted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_payment` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_id` int NOT NULL,
  `users_id` int NOT NULL,
  `claim_number` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `claim_amount` float NOT NULL,
  `vat` enum('0','15') COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `invoice_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_paiement_status` (`status_id`),
  KEY `fk_paiement_users` (`users_id`),
  KEY `fk_paiement_claims` (`claim_number`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `payment`
--

INSERT INTO `payment` (`id`, `invoice_no`, `date_submitted`, `date_payment`, `status_id`, `users_id`, `claim_number`, `claim_amount`, `vat`, `invoice_date`) VALUES
(1, '230736', '2025-07-29 21:00:00', '2025-07-15 21:00:00', 6, 5, 'M0119921', 10000, '15', '2025-08-11 10:40:10'),
(2, '23076', '2025-07-29 21:00:00', '2025-07-15 21:00:00', 6, 5, 'M0119926', 20000, '15', '2025-08-11 10:40:10'),
(3, '230737', '2025-07-27 21:00:00', '2025-07-27 21:00:00', 7, 5, 'M0119927', 372999, '', '2025-08-11 10:40:10'),
(4, '230738', '2025-07-24 21:00:00', '2025-07-25 21:00:00', 7, 5, 'M0119923', 787834, '', '2025-08-11 10:40:10'),
(5, '230739', '2025-07-19 21:00:00', '2025-07-21 21:00:00', 7, 5, 'M0119924', 12000, '', '2025-08-11 10:40:10'),
(6, '230740', '2025-07-18 21:00:00', '2025-07-20 21:00:00', 8, 5, 'M0119925', 21999, '', '2025-08-11 10:40:10'),
(7, '230741', '2025-07-28 21:00:00', '2025-07-29 21:00:00', 6, 5, 'M0119928', 787372, '', '2025-08-11 10:40:10'),
(8, '230742', '2025-07-26 21:00:00', '2025-07-27 21:00:00', 7, 5, 'M0119929', 10377, '', '2025-08-11 10:40:10'),
(9, '230743', '2025-07-25 21:00:00', '2025-07-26 21:00:00', 8, 5, 'M0119930', 107392, '', '2025-08-11 10:40:10'),
(10, '230744', '2025-07-24 21:00:00', '2025-07-25 21:00:00', 6, 5, 'M0119931', 7837720, '', '2025-08-11 10:40:10'),
(11, '230745', '2025-07-23 21:00:00', '2025-07-24 21:00:00', 7, 5, 'M0119932', 1783770, '', '2025-08-11 10:40:10');

-- --------------------------------------------------------

--
-- Structure de la table `roles`
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
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`id`, `role_code`, `role_name`, `description`, `updated_at`) VALUES
(1, 'surveyor', 'Surveyor', 'Utilisateur qui fait la vérificatoin', '2025-06-26 22:08:34'),
(2, 'garage', 'Garage', 'Utilisateur qui fait la réparation', '2025-06-26 22:08:34'),
(3, 'spare_part', 'Spare Part', 'Utilisateur qui est le fournisseur des pièces', '2025-06-26 22:09:57'),
(4, 'car_rentale', 'Car Rentale', 'Utilisateur pour la location voiture', '2025-06-26 22:09:57');

-- --------------------------------------------------------

--
-- Structure de la table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(45) DEFAULT NULL,
  `status_name` varchar(45) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `status`
--

INSERT INTO `status` (`id`, `status_code`, `status_name`, `description`) VALUES
(1, 'new', 'New', 'Première statut des claims après affectatin'),
(2, 'draft', 'Draft', 'Status pendant intervention d\'un utilisateur'),
(3, 'in_progress', 'In Progress', 'Status après submit des formulaires'),
(4, 'completed', 'Completed', 'Status quand le paiement est effectué'),
(5, 'rejected', 'Rejected', 'Statut pour rejecter un claim'),
(6, 'under review', 'Under review', 'Paiement en cours d\'évaluation'),
(7, 'paid', 'Paid', 'payé'),
(8, 'approved', 'Approved', 'Paiement approuvé'),
(9, 'queries', 'Queries', 'status querie');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `created_at`, `updated_at`) VALUES
(1, '2025-06-23 07:54:40', '2025-06-23 07:54:40'),
(2, '2025-06-23 07:54:46', '2025-06-23 07:54:46'),
(3, '2025-06-23 07:54:53', '2025-06-23 07:54:53'),
(4, '2025-06-26 22:49:06', '2025-06-26 22:49:06'),
(5, '2025-06-26 22:49:14', '2025-06-26 22:49:14'),
(6, '2025-06-26 22:53:25', '2025-06-26 22:53:25'),
(7, '2025-06-26 22:53:30', '2025-06-26 22:53:30'),
(8, '2025-07-23 10:12:06', '2025-07-23 10:12:06'),
(9, '2025-07-23 10:12:35', '2025-07-23 10:12:35'),
(10, '2025-07-23 10:14:34', '2025-07-23 10:14:34'),
(11, '2025-07-24 10:40:18', '2025-07-24 10:40:18');

-- --------------------------------------------------------

--
-- Structure de la table `user_roles`
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
-- Déchargement des données de la table `user_roles`
--

INSERT INTO `user_roles` (`users_id`, `roles_id`, `assigned_at`, `is_active`) VALUES
(1, 1, '2025-06-26 22:47:37', 1),
(2, 2, '2025-06-26 22:47:37', 1),
(3, 3, '2025-06-26 22:48:09', 1),
(4, 1, '2025-06-26 22:53:08', 1),
(5, 1, '2025-06-26 22:53:08', 1),
(6, 2, '2025-06-26 22:56:16', 1),
(7, 3, '2025-06-26 22:56:16', 1),
(11, 1, '2025-07-24 10:40:18', 1);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `account_informations`
--
ALTER TABLE `account_informations`
  ADD CONSTRAINT `fk_account_informations_users` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Contraintes pour la table `administrative_settings`
--
ALTER TABLE `administrative_settings`
  ADD CONSTRAINT `fk_administrative_settings_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Contraintes pour la table `admin_settings_communications`
--
ALTER TABLE `admin_settings_communications`
  ADD CONSTRAINT `FK_42D45B45260B1BF7` FOREIGN KEY (`admin_setting_id`) REFERENCES `administrative_settings` (`id`),
  ADD CONSTRAINT `fk_admin_settings_communication_communication_methods1` FOREIGN KEY (`method_id`) REFERENCES `communication_methods` (`id`);

--
-- Contraintes pour la table `assignment`
--
ALTER TABLE `assignment`
  ADD CONSTRAINT `fk_assignment_status1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`),
  ADD CONSTRAINT `fk_assignment_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Contraintes pour la table `claims`
--
ALTER TABLE `claims`
  ADD CONSTRAINT `fk_claims_status1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`);

--
-- Contraintes pour la table `financial_informations`
--
ALTER TABLE `financial_informations`
  ADD CONSTRAINT `fk_financial_informations_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);

--
-- Contraintes pour la table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `fk_user_roles_Roles1` FOREIGN KEY (`roles_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `fk_user_roles_users1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
