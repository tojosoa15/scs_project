<?php

namespace App\Controller;

use App\Entity\ClaimUser\Claims;
use App\Repository\ClaimRepository;
use App\Service\ClaimUserDbService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimsByUserController extends AbstractController
{
    public function __construct(
        private ClaimUserDbService $claimUserDbService,
        private EntityManagerInterface $em,
        private ClaimRepository $claimRepository
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $params = $request->query->all();

        if (empty($params['email'])) {
            try {
                $claims = $this->claimUserDbService->callGetAllClaims([
                    'page' => (int)($query['page'] ?? 1),
                    'page_size' => (int)($query['page_size'] ?? 10),
                ]);
                // $claims = $this->claimRepository->findAll();
                return new JsonResponse($claims);
    
            } catch (\Exception $e) {
                return new JsonResponse(
                    ['error' => $e->getMessage()],
                    JsonResponse::HTTP_INTERNAL_SERVER_ERROR
                );
            }
        } else {
            try {
                $results = $this->claimUserDbService->callGetListByUser([
                    'email' => $params['email'],
                    'f_status' => $params['f_status'] ?? null,
                    'search_name' => $query['search_name'] ?? null,
                    'sort_by' => $query['sort_by'] ?? 'date',
                    'page' => (int)($query['page'] ?? 1),
                    'page_size' => (int)($query['page_size'] ?? 10),
                    'search_num' => $query['search_num'] ?? null,
                    'search_reg_num' => $query['search_reg_num'] ?? null,
                    'search_phone' => $query['search_phone'] ?? null
                ]);
    
                return new JsonResponse($results);
    
            } catch (\Exception $e) {
                return new JsonResponse(
                    ['error' => $e->getMessage()],
                    JsonResponse::HTTP_INTERNAL_SERVER_ERROR
                );
            }
        }

    }
}