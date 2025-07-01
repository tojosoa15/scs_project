<?php

namespace App\Controller;

use App\Service\ClaimUserDbService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class UpdateUserWebsiteController extends AbstractController
{
    public function __construct(private ClaimUserDbService $claimUserDbService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $resFormat = [];

        $params = $request->query->all();

        if (empty($params['p_email_address']) && empty($params['p_new_website'])) {
            return new JsonResponse(
                ['error' => 'p_email_address and  parameter are required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimUserDbService->callUpdateUserWebsite([
                'p_email_address'   => $params['p_email_address'],
                'p_new_website'     => $params['p_new_website']
            ]);
            
            return new JsonResponse([
                'status'    => 'success',
                'data'      => $results
            ], JsonResponse::HTTP_OK);


        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage(), 'message' => 'Updated failed.'],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}