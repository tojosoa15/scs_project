<?php

namespace App\Service;

use Doctrine\DBAL\Connection;

class ClaimDetailsService
{
    private Connection $connection;

    public function __construct(Connection $claimDetailsConnection)
    {
        $this->connection = $claimDetailsConnection;
    }

    public function callGetClaimDetails(array $params): array
    {
        $sql = "CALL GetClaimDetails(?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_email']);
        
        return $stmt->executeQuery()->fetchAssociative();
    }

    public function callSpVerificationProcessSurveyor(array $params): array
    {
        $sql = "CALL SpVerificationProcessSurveyor(?, ?, ?, ?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_surveyor_id']);
        $stmt->bindValue(3, $params['p_status']);
        $stmt->bindValue(4, $params['p_current_step']);
        $stmt->bindValue(5, $params['p_json_data']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    public function callGetSummary(array $params): array
    {
        $sql = "CALL GetSummary(?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_email']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    public function callGetSummary_backup(array $params): array
    {
        $pdo = $this->connection->getNativeConnection(); // Retourne un \PDO natif
    
        $stmt = $pdo->prepare("CALL GetSummary(:claim_number, :email)");
        $stmt->bindValue(':claim_number', $params['p_claim_number']);
        $stmt->bindValue(':email', $params['p_email']);
        $stmt->execute();
    
        $summaries = [];
    
        // 1. Survey Information
        $summaries['survey_information'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
    
        // 2. Vehicle Information
        if ($stmt->nextRowset()) {
            $summaries['vehicle_information'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 3. Part Summary
        if ($stmt->nextRowset()) {
            $summaries['part_summary'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 4. Labour Summary
        if ($stmt->nextRowset()) {
            $summaries['labour_summary'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 5. Grand Totals
        if ($stmt->nextRowset()) {
            $summaries['grand_totals'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        return $summaries;
    } 
}