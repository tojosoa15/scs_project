<?php

namespace App\Repository;

use App\Entity\ClaimUser\Document;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Document>
 */
class DocumentRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Document::class);
    }

   /**
     * Récupérer tous les documents d'un utilisateur
     */
   public function findByUserId(
    int $userId,
    ?string $searchName = null,   
    ?string $sortBy = 'ASC' 
    ): array
    {
        $qb = $this->createQueryBuilder('d')
            ->where('d.users = :userId')
            ->setParameter('userId', $userId);

        // Filtre sur le nom si fourni
        if ($searchName) {
            $qb->andWhere('d.name LIKE :name')
            ->setParameter('name', '%' . $searchName . '%');
        }

        // Tri sur la date
        $qb->orderBy('d.date', $sortBy);

        return $qb->getQuery()->getResult();
    }


    /**
     * Récupérer un seul document avec userId + documentId
     */
    public function findOneByUserAndDocumentId(int $userId, int $documentId): ?Document
    {
        return $this->createQueryBuilder('d')
            ->where('d.users = :userId')
            ->andWhere('d.id = :documentId')
            ->setParameter('userId', $userId)
            ->setParameter('documentId', $documentId)
            ->getQuery()
            ->getOneOrNullResult();
    }


}
