<?php
// src/Controller/AuthController.php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\Service\ClaimUserDbService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Core\Exception\AuthenticationException;

class AffectionClaimController extends AbstractController
{
    public function __construct(private ClaimUserDbService $claimUserDbService) {}

    /**
     * Handles the affection claim process.
     * 
     */
    public function __invoke(Request $request): JsonResponse
    {
        // $results = $this->claimUserDbService->callPostAffectionClaim($params);
        $params = (array)json_decode($request->getContent(), true);
 
        if (empty($params['p_claims_number']) && empty($params['p_users_id'])) {
            return new JsonResponse(
                ['error' => 'p_claims_number et p_users_id parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
        
        try {
            $this->claimUserDbService->callPostAffectionClaim($params);

            return new JsonResponse([
                'status'    => 'success'
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}