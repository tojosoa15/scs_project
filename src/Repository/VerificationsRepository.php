<?php
// src/Repository/UsersRepository.php

namespace App\Repository;

use App\Entity\Verifications;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class VerificationsRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Verifications::class);
    }

    public function findIdByClaimAndUser($claimsId, $userId)
    {
        return $this->createQueryBuilder('v')
            ->where('v.claimsId = :claimsId')
            ->setParameter('claimsId', $claimsId)
            ->andWhere('v.userId = :userId')
            ->setParameter('userId', $userId)
            ->getQuery()
            ->getOneOrNullResult();
    }


    public function findIdByClaimAndUserTst($claimsId, $userId)
    {
        return $this->createQueryBuilder('v')
            ->select (
                'v.id',
                'v.claimsId',
                'v.userId',
            )
            ->where('v.claimsId = :claimsId')
            ->setParameter('claimsId', $claimsId)
            ->andWhere('v.userId = :userId')
            ->setParameter('userId', $userId)
            ->getQuery()
            ->getOneOrNullResult();
    }
}