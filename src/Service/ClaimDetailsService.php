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
        
        return $stmt->executeQuery()->fetchAllAssociative();
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
        $sql = "CALL GetClaimDetails(?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_email']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }
}