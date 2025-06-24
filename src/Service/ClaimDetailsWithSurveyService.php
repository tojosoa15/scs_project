<?php

namespace App\Service;

use Doctrine\DBAL\Connection;

class ClaimDetailsWithSurveyService
{
    private Connection $connection;

    public function __construct(Connection $claimDetailsWithSurveyConnection)
    {
        $this->connection = $claimDetailsWithSurveyConnection;
    }

    public function callGetClaimDetailsWithSurvey(array $params): array
    {
        $sql = "CALL GetClaimDetailsWithSurvey(?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['id']);

        
        return $stmt->executeQuery()->fetchAllAssociative();
    }
}