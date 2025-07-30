<?php

namespace App\Controller;

use App\Entity\ClaimUser\Paiement;
use App\Service\ClaimUserDbService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class PaymentController extends AbstractController
{
    public function __construct(
        private ClaimUserDbService $claimUserDbService,
        private EntityManagerInterface $em,
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $params = $request->query->all();

        try {
            $payments = $this->claimUserDbService->callGetPaiementListByUser([
                'p_email'           => $params['email'],
                'p_status'          => $params['status'] ?? null,
                'p_invoice_no'      => $query['searchName'] ?? null,
                'p_claim_number'    => $query['searchPhone'] ?? null,
                'p_sort_by'         => $query['sortBy'] ?? 'date',
                'p_page'            => (int)($query['page'] ?? 1),
                'p_page_size'       => (int)($query['pageSize'] ?? 10)
            ]);
            
            return new JsonResponse([
                'status' => 'success',
                'code'  => JsonResponse::HTTP_OK,
                'message' => 'Successful payment list.',
                'data' => $payments
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [   'error' => $e->getMessage(), 'message' => 'Roles retrieval failed.'],
                    JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}