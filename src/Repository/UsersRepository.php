<?php
// src/Repository/UsersRepository.php

namespace App\Repository;

use App\Entity\AdministrativeSettings;
use App\Entity\AdminSettingsCommunications;
use App\Entity\CommunicationMethods;
use App\Entity\Users;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class UsersRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Users::class);
    }

    // public function findWithAccountInfo(int $id) 
    // {
    //     $user = $this->find($id);
    //     dd($user->getAccountInformation()); // Vérifiez si l'objet est bien chargé
    //     return $user;
    // }

    // Liste des utilisateurs
    public function getListUsers($query) {
        $qb = $this->createQueryBuilder('u')
            ->select(
                'u.id',
                'ac.emailAddress',
                'rl.id as role_id', 
                'rl.roleName as role_name'
            )
            ->leftJoin('u.roles', 'rl')
            ->leftJoin('u.accountInformation', 'ac');

        if (isset($query['role'])) {
            $qb->where('rl.roleCode = :role')
                ->setParameter('role', $query['role']);
        }
        
        return $qb->getQuery()
                ->getResult();
    }

    // Retourne l'information utilisateur
    public function getProfilUser($param) {
        $qb = $this->createQueryBuilder('u')
            ->select(
                'u.id as user_id',
                'ai.businessName',
                'ai.businessRegistrationNumber',
                'ai.businessAddress',
                'ai.city',
                'ai.postalCode',
                'ai.phoneNumber',
                'ai.emailAddress',
                'ai.website', 
                'fi.vatNumber',
                'fi.taxIdentificationNumber',
                'fi.bankName',
                'fi.bankAccountNumber',
                'fi.swiftCode',
                'ads.primaryContactName',
                'ads.primaryContactPost',
                'ads.notification',
                'cm.methodName as communicationMethod' 
                // '' ici je voudrais la liste des communicationMethod qui est stocker dans la table AdminSettingsCommunictions
            )
            ->leftJoin('u.accountInformation', 'ai')
            ->leftJoin('u.financialInformation', 'fi')
            ->leftJoin('u.administrativeSettings', 'ads')
            ->leftJoin('ads.communicationMethods', 'cm'); // Relation ManyToMany ave ads

        // Si c'est un ID (numérique)
        if (is_numeric($param)) {
            $qb->where('u.id = :param');
        } 
        // Sinon, traite comme un email
        else {
            $qb->where('ai.emailAddress = :param');
        }

        $result = $qb
            ->setParameter('param', $param)
            ->getQuery()
            ->getResult();
        
        return $result;
    }
}