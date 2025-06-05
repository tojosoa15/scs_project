<?php
// src/Repository/UsersRepository.php

namespace App\Repository;

use App\Entity\Payements;
use App\Entity\Users;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class PayementsRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Payements::class);
    }

    // public function findWithAccountInfo(int $id) 
    // {
    //     $user = $this->find($id);
    //     dd($user->getAccountInformation()); // Vérifiez si l'objet est bien chargé
    //     return $user;
    // }

    public function getListPayementUser($query, $dateStart, $dateEnd) {
        $qb = $this->createQueryBuilder('p')
            ->select(
                'p.id',
                'p.dateSubmitted',
                'p.invoiceNum', 
                'p.claimNum',
                'p.claimAmount',
                'p.payementDate',
                'st.statusName'
            )
            ->leftJoin('p.users', 'u')
            ->leftJoin('p.status', 'st');

        // Filtre par utilisateur
        if (isset($query['user_id'])) {
            $qb->where('u.id = :user_id')
                ->setParameter('user_id', intval($query['user_id']));
        }

        // Recherche par numéro de claim
        if (isset($query['claimNo'])) {
            $qb->andWhere('p.claimNum = :claimNo')
                ->setParameter('claimNo', $query['claimNo']);
        }

        // Filtre par status
        if (isset($query['status'])) {
            $qb->andWhere('st.statusCode = :status')
                ->setParameter('status', $query['status']);
        }

        // Filtre par invoice number
        if (isset($query['invoiceNo'])) {
            $qb->andWhere('p.invoiceNum = :invoiceNo')
                ->setParameter('invoiceNo', $query['invoiceNo']);
        }

        // Filtre par plage de dates : cas export
        if ($dateStart && $dateEnd) {
            $qb->andWhere('p.dateSubmitted BETWEEN :dateStart AND :dateEnd')
                ->setParameter('dateStart', $dateStart)
                ->setParameter('dateEnd', $dateEnd);
        }

        // Trier par date d'enregistrement
        if (isset($query['dateSubmited']) && $query['dateSubmited'] == 'true') {
            $qb->orderBy('p.dateSubmitted', 'DESC');
        } else {
            $qb->orderBy('p.dateSubmitted', 'ASC');
        }


        // Trier par date de paiement
        if(isset($query['payementDate']) && $query['payementDate'] == 'true') {
            $qb->orderBy('p.payementDate', 'DESC');
        } else {
            $qb->orderBy('p.payementDate', 'ASC');
        }

        
        return $qb->getQuery()
                ->getResult();
    }
}