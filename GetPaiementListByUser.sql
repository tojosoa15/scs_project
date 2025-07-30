DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPaiementListByUser`(
    IN `p_email` VARCHAR(255),
    IN `p_status` VARCHAR(255),
    IN `p_invoice_no` VARCHAR(100),
    IN `p_claim_number` VARCHAR(100),
    IN `p_sort_by` VARCHAR(50),
    IN `p_page` INT,
    IN `p_page_size` INT,
    IN `p_start_date` DATETIME,
    IN `p_end_date` DATETIME
)
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN
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
        FROM paiement P
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
        FROM paiement P
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

DELIMITER ;