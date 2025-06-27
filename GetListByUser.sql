USE [claim_processing]
GO

/****** Object:  StoredProcedure [dbo].[GetListByUser]    Script Date: 27/05/2025 14:47:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetListByUser]
    @email VARCHAR(255) ='',               -- identifiant user 
    @f_status VARCHAR(255) = '',       -- filtre par statut
    @search_name VARCHAR(255) = '',    -- recherche par nom de claim
    @sort_by VARCHAR(50) = 'date',     -- tri : 'date' ou 'status'
    @page INT = 1,                     -- numéro de page
    @page_size INT = 10,               -- nombre d'éléments par page
    @search_num VARCHAR(255) = '',
    @search_reg_num VARCHAR(255) = '',
    @search_phone VARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation du paramètre d'entrée
    IF @email IS NULL OR LTRIM(RTRIM(@email)) = ''
    BEGIN
        RAISERROR('L''email est un paramètre obligatoire et ne peut pas être vide.', 16, 1);
        RETURN;
    END

    -- Vérification que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM account_informations WHERE email_address = @email)
    BEGIN
        RAISERROR('Aucun utilisateur trouvé avec cet email.', 16, 1);
        RETURN;
    END

    DECLARE @where NVARCHAR(MAX) = ' WHERE 1=1 ';
    DECLARE @order_by NVARCHAR(MAX);
    DECLARE @offset INT = (@page - 1) * @page_size;
    DECLARE @sql NVARCHAR(MAX);

    -- Filtrer par statut
    IF LTRIM(RTRIM(@f_status)) != ''
        SET @where += ' AND ST.status_name = @f_status';

    -- Recherche par nom
    IF LTRIM(RTRIM(@search_name)) != ''
        SET @where += ' AND CL.name LIKE @search_name';

    -- Recherche par numéro
    IF LTRIM(RTRIM(@search_num)) != ''
        SET @where += ' AND CL.number LIKE @search_num';

    -- Recherche par numéro de registration
    IF LTRIM(RTRIM(@search_reg_num)) != ''
        SET @where += ' AND CL.registration_number LIKE @search_reg_num';

    -- Recherche par téléphone
    IF LTRIM(RTRIM(@search_phone)) != ''
        SET @where +=' AND CL.phone LIKE @search_phone';

    -- Filtrer par utilisateur connecté (email)
    SET @where += ' AND ACI.email_address = @email';

    -- Tri par statut, date ou vieillissement
    IF @sort_by = 'status'
        SET @order_by = ' ORDER BY SA.status ASC ';
    ELSE IF @sort_by = 'received_date'
        SET @order_by = ' ORDER BY CL.received_date DESC '; -- Tri par date décroissante
    ELSE 
        SET @order_by = ' ORDER BY CL.ageing DESC ';

    SET @sql = '
        SELECT 
   		CL.id AS claim_id,
   		CL.received_date,
   		CL.number,
   		CL.name,
   		CL.registration_number,
   		CL.ageing,
   		CL.phone,
   		ST.status_name
	FROM 
   		claims CL
   		INNER JOIN surveyor_assignment SA ON CL.id = SA.claims_id
   		INNER JOIN users US ON US.id = SA.surveyor_id
   		INNER JOIN account_informations ACI ON ACI.users_id = US.id
   		INNER JOIN status ST ON ST.id = SA.status_id
        ' + @where + @order_by + '
        OFFSET ' + CAST(@offset AS NVARCHAR) + ' ROWS 
        FETCH NEXT ' + CAST(@page_size AS NVARCHAR) + ' ROWS ONLY
		FOR JSON PATH;
    ';

    -- Exécution sécurisée avec le paramètre @email utilisé
    EXEC sp_executesql 
        @sql, 
        N'@f_status VARCHAR(255), @search_name VARCHAR(255), @search_num VARCHAR(255), @search_reg_num VARCHAR(255), @search_phone VARCHAR(255), @email VARCHAR(255)', 
        @f_status = @f_status,
        @search_name = @search_name,
        @search_num = @search_num,
        @search_reg_num = @search_reg_num,
        @search_phone = @search_phone,
        @email = @email;
END
GO


