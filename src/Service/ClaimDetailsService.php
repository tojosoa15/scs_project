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
        $sql = "CALL GetClaimDetails(?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);

        
        return $stmt->executeQuery()->fetchAllAssociative();
    }
}