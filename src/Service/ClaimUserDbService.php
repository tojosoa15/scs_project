<?php

namespace App\Service;

use Doctrine\DBAL\Connection;

class ClaimUserDbService
{
    private Connection $connection;

    public function __construct(Connection $claimUserDbConnection)
    {
        $this->connection = $claimUserDbConnection;
    }

    /**
     * Liste des claims d'un utilisateur (dashboard)
     * 
     * @param array $params
     * @return array
     */
    public function callGetListByUser(array $params): array
    {
        $sql = "CALL GetListByUser(?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['email']);
        $stmt->bindValue(2, $params['f_status'] ?? null);
        $stmt->bindValue(3, $params['search_name']);
        $stmt->bindValue(4, $params['sort_by']);
        $stmt->bindValue(5, $params['page'], \PDO::PARAM_INT);
        $stmt->bindValue(6, $params['page_size'], \PDO::PARAM_INT);
        $stmt->bindValue(7, $params['search_num']);
        $stmt->bindValue(8, $params['search_reg_num']);
        $stmt->bindValue(9, $params['search_phone']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    /**
     * Information utilisateur pour visualiser et gerer profile
     * 
     * @param array $params
     * @return array
     */
    public function callGetUserProfile(array $params): array
    {
        $sql = "CALL GetUserProfile(?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    /**
     * Retourne tous les claims
     * 
     * @param array $params
     * @return array
     */
    public function callGetAllClaims(array $params) : array 
    {
        $sql = "CALL GetAllClaims(?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['page'], \PDO::PARAM_INT);
        $stmt->bindValue(2, $params['page_size'], \PDO::PARAM_INT);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    /**
     * Retourne tous les roles
     * 
     * @param array $params
     * @return array
     */
    public function callAllRoles(array $params) : array 
    {
        $sql = "CALL GetAllRoles(?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['page'], \PDO::PARAM_INT);
        $stmt->bindValue(2, $params['page_size'], \PDO::PARAM_INT);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    /**
     * Retourne les utilisateur par role
     * 
     * @param array $params
     * @return array
     */
    public function callGetUserByRole(array $params) : array {
        $sql = "CALL GetUserByRole(?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['role_id']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    /**
     * Mise à jour du site web de l'utilisateur
     * 
     * @param array $params
     * @return array
     */
    public function callUpdateUserWebsite(array $params) : array
    {
        $sql = "CALL UpdateUserWebsite(?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);
        $stmt->bindValue(2, $params['p_new_website']);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }

    /**
     * Mise à jour des paramètres administratifs
     * 
     * @param array $params
     * @return array
     */
    public function callUpdateAdminSetting(array $params) : array
    {
        $sql = "CALL UpdateAdminSettings(?, ?, ?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);
        $stmt->bindValue(2, $params['p_primary_contact_name'] ?? null);
        $stmt->bindValue(3, $params['p_primary_contact_post'] ?? null);
        $stmt->bindValue(4, $params['p_notification'] ?? null);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }

    /**
     * Mise à jour du mot de passe utilisateur
     * 
     * @param array $params
     * @return array
     */
    public function callUpdateUserPassword(array $params) : array
    {
        $sql = "CALL UpdateUserPassword(?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);
        $stmt->bindValue(2, $params['p_new_password'] ?? null);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }

    /**
     * Vérifie si l'email existe pour la récupération de mot de passe
     * 
     * @param array $params
     * @return array
     */
    public function callForgotPassword(array $params) : array
    {
        $sql = "CALL ChekEmailExists(?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }

    /**
     * Authentification de l'utilisateur
     * 
     * @param array $params
     * @return array
     */
    public function callAuthentification(array $params) : array         
    {
        $sql = "CALL AuthentificateUser(?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_email_address']);
        $stmt->bindValue(2, $params['p_password']);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }

    public function callPostAffectionClaim(array $params) : array         
    {
        $sql = "CALL InsertAssignment(?, ?, ?, ?, ?, ?)";

        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claims_id']);
        $stmt->bindValue(2, $params['p_users_id']);
        $stmt->bindValue(3, $params['p_assignment_date']);
        $stmt->bindValue(4, $params['p_assignement_note']);
        $stmt->bindValue(5, $params['p_status_id']);
        $stmt->bindValue(6, $params['p_claims_number']);

        return $stmt->executeQuery()->fetchAllAssociative();
        
    }
            
}