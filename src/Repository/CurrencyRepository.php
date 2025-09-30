<?php

namespace App\Repository;

use App\Entity\Scs\CurrencyType;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class CurrencyRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, CurrencyType::class);
    }

    /**
     * Retourne tous les transaction types triés par nom
     */
    public function findAllCurrency(): array
    {
        return $this->createQueryBuilder('tt')
            ->select('tt.id', 'tt.name')
            ->orderBy('tt.name', 'ASC')
            ->getQuery()
            ->getArrayResult();
    }
}
