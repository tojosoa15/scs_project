<?php

namespace App\Controller;
use App\Service\ClaimUserDbService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimPartialInfoByNumberController extends AbstractController
{
    public function __construct(
        private ClaimUserDbService $claimUserDbService
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $params = $request->query->all();

        if (empty($params['claimNo']) && empty($params['email'])) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Claim Number and Email parameter is required'
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
        
        try {
            $results = $this->claimUserDbService->callGetClaimPartial([
                'p_claim_number'    => $params['claimNo'],
                'p_email'           => $params['email']
            ]);
            foreach ($results as $res) {
                $resFormat = [
                    'claim_number'  => $res['claim_number'],
                    'vehicle_information' => [
                        'id'                        => $res['id'],
                        'make'                      => $res['make'],
                        'model'                     => $res['model'],
                        'cc'                        => $res['cc'],    
                        'fuel_type'                 => $res['fuel_type'],    
                        'transmission'              => $res['transmission'],    
                        'engine_no'                 => $res['engine_no'],    
                        'chasis_no'                 => $res['chasis_no'],
                        'vehicle_no'                => $res['vehicle_no']
                    ],
                    'survey_information' => [
                        'garage'            => $res['garage'],
                        'garage_address'    => $res['garage_address'],
                        'garage_contact_no' => $res['garage_contact_no'],
                        'eor_value'         => $res['eor_value']
                    ]
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful Claim partial information retrieval.',
                'data'      => $resFormat
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => 'Claim retrieval failed.'
                ],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

}