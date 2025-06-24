<?php

namespace App\Controller;

use App\Service\ClaimDetailsWithSurveyService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimDetailsWithSurveyController extends AbstractController
{
    public function __construct(private ClaimDetailsWithSurveyService $claimDetailsWithSurveyService) {}

    public function __invoke(Request $request): JsonResponse
    {
        // return new JsonResponse('test');

        $params = $request->query->all();

        if (empty($params['id'])) {
            return new JsonResponse(
                ['error' => 'Id parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimDetailsWithSurveyService->callGetClaimDetailsWithSurvey([
                'id' => $params['id']
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