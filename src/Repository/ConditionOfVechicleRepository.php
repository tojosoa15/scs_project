<?php
    // src/Repository/UsersRepository.php

    namespace App\Repository;

    use App\Entity\ConditionOfVechicle;
    use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
    use Doctrine\Persistence\ManagerRegistry;

    class ConditionOfVechicleRepository extends ServiceEntityRepository
    {
        public function __construct(ManagerRegistry $registry)
        {
            parent::__construct($registry, ConditionOfVechicle::class);
        }
    }