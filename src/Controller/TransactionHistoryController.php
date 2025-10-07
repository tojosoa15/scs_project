<?php

namespace App\Controller;

use App\Entity\Scs\Transaction;
use App\Repository\TransactionTypeRepository;
use App\Repository\CurrencyRepository;
use App\Service\TransactionService;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class TransactionHistoryController extends AbstractController
{
    public function __construct(
        private EntityManagerInterface $em,
        ManagerRegistry $doctrine,
        private TransactionTypeRepository $transactionTypeRepository,
        private CurrencyRepository $currencyRepository,
        private TransactionService $transactionService

    ) {
        $this->em = $doctrine->getManager('scs_db');
    }

    /**
     * Récupérer l’historique des transactions d’un utilisateur
     */
    public function getAllTransactionHistory(Request $request): JsonResponse
    {
        $userId = $request->query->get('userId');

        if (!$userId) {
            return $this->json([
                'status'  => 'error',
                'code'    => JsonResponse::HTTP_BAD_REQUEST,
                'message' => 'userId parameter is required',
            ], JsonResponse::HTTP_BAD_REQUEST);
        }

        try {
            // $transactions = $this->em->getRepository(Transaction::class)->findByUserId(intval($userId));
            $params = $request->query->all();

            // Manage array or single string for fund name filter
            // if (!empty($params['searchFundName']) && is_string($params['searchFundName'])) {
            //     $params['searchFundName'] = array_map('trim', explode(',', $params['searchFundName']));
            // } 
            if (!empty($params['searchFundName']) && is_string($params['searchFundName'])) {
                if (strpos($params['searchFundName'], ',') !== false) {
                    // Plusieurs valeurs séparées par virgule → transforme en tableau
                    $params['searchFundName'] = array_map('trim', explode(',', $params['searchFundName']));
                } else {
                    // Une seule valeur → laisse en string pour LIKE
                    $params['searchFundName'] = trim($params['searchFundName']);
                }
            }

            // Manage array for reference filter
            // if (!empty($params['searchReference']) && is_string($params['searchReference'])) {
            //     $params['searchReference'] = array_map('trim', explode(',', $params['searchReference']));
            // }
            if (!empty($params['searchReference']) && is_string($params['searchReference'])) {
                if (strpos($params['searchReference'], ',') !== false) {
                    // Plusieurs valeurs séparées par virgule → transforme en tableau
                    $params['searchReference'] = array_map('trim', explode(',', $params['searchReference']));
                } else {
                    // Une seule valeur → laisse en string pour LIKE
                    $params['searchReference'] = trim($params['searchReference']);
                }
            }

            // Manage array for transaction type filter
            if (!empty($params['searchTransactionType']) && is_string($params['searchTransactionType'])) {
                $params['searchTransactionType'] = array_map('trim', explode(',', $params['searchTransactionType']));
            }

            // Manage array for currency filter
            if (!empty($params['searchCurrency']) && is_string($params['searchCurrency'])) {
                $params['searchCurrency'] = array_map('trim', explode(',', $params['searchCurrency']));
            }

            $transactions = $this->em
                ->getRepository(Transaction::class)
                ->findByUserIdWithFilters($params);

            if (empty($transactions)) {
                return $this->json([
                    'status'  => 'success',
                    'code'    => JsonResponse::HTTP_OK,
                    'message' => 'No transaction found for this user.',
                    'data'    => null,
                ], JsonResponse::HTTP_OK);
            }

            return $this->json([
                'status'  => 'success',
                'code'    => JsonResponse::HTTP_OK,
                'message' => 'Successful transaction list.',
                'data'    => $transactions,
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return $this->json([
                'status'  => 'error',
                'code'    => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                'message' => $e->getMessage(),
            ], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Récupérer tous les types de documents
     */
    public function getAllDocumentType(): JsonResponse
    {
        try {
            $types = $this->transactionTypeRepository->findAllTypes();

            return $this->json([
                'status'  => 'success',
                'code'    => JsonResponse::HTTP_OK,
                'message' => 'Successful TransactionType list.',
                'data'    => $types,
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return $this->json([
                'status'  => 'error',
                'code'    => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                'message' => $e->getMessage(),
            ], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Récupérer toutes les devises
     */
    public function getAllCurrency(): JsonResponse
    {
        try {
            $types = $this->currencyRepository->findAllCurrency();

            return $this->json([
                'status'  => 'success',
                'code'    => JsonResponse::HTTP_OK,
                'message' => 'Successful Currency list.',
                'data'    => $types,
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return $this->json([
                'status'  => 'error',
                'code'    => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                'message' => $e->getMessage(),
            ], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
 * Export des transactions (PDF ou Excel)
 *
 * @param Request $request
 */
public function transactionExport(Request $request)
{
    $userId = $request->query->get('userId');
    $type = $request->query->get('type', 'pdf');

    if (!$userId) {
        return $this->json([
            'status'  => 'error',
            'code'    => JsonResponse::HTTP_BAD_REQUEST,
            'message' => 'userId parameter is required',
        ], JsonResponse::HTTP_BAD_REQUEST);
    }

    try {
        $params = $request->query->all();

        // Gérer les filtres multiples
        $multiFields = ['searchFundName', 'searchReference', 'searchTransactionType', 'searchCurrency'];
        foreach ($multiFields as $field) {
            if (!empty($params[$field]) && is_string($params[$field])) {
                if (strpos($params[$field], ',') !== false) {
                    $params[$field] = array_map('trim', explode(',', $params[$field]));
                } else {
                    $params[$field] = trim($params[$field]);
                }
            }
        }

        // Récupération des transactions
        $transactions = $this->em
            ->getRepository(Transaction::class)
            ->findByUserIdWithFilters($params);

        if (empty($transactions)) {
            return $this->json([
                'status'  => 'success',
                'code'    => JsonResponse::HTTP_OK,
                'message' => 'No transaction found for this user.',
                'data'    => null,
            ], JsonResponse::HTTP_OK);
        }

        // 🔸 Export PDF ou Excel
        if ($type === 'pdf') {
            return $this->transactionService->generatePdf($transactions);
        } elseif ($type === 'excel') {
            return $this->transactionService->generateExcel($transactions);
        } elseif ($type === 'csv') {
            return $this->transactionService->generateCsv($transactions);
        }

        throw new \Exception("Type d'export non reconnu : $type");

    } catch (\Exception $e) {
        return new JsonResponse(
            [
                'status'    => 'error',
                'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                'message'   => $e->getMessage()
            ],
            JsonResponse::HTTP_INTERNAL_SERVER_ERROR
        );
    }
}

}
