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
}