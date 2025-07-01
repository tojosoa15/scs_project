<?php

namespace App\Controller;

use App\Service\ClaimDetailsService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimDetailsController extends AbstractController
{
    public function __construct(private ClaimDetailsService $claimDetailsService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $resFormat = [];

        $params = $request->query->all();

        if (empty($params['p_claim_number'])) {
            return new JsonResponse(
                ['error' => 'Id parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimDetailsService->callGetClaimDetails([
                'p_claim_number' => $params['p_claim_number']
            ]);

            foreach ($results as $res) {
                $resFormat = [
                    'claim_number'  => $res['claim_number'],
                    'status_name'   => $res['status_name'],
                    'vehicle_informatin' => [
                        'make'                      => $res['make'],
                        'model'                     => $res['model'],
                        // 'cc'                        => $res['cc'],
                        // 'fuel_type'                 => $res['fuel_type'],
                        // 'transmission'              => $res['transmission'],
                        // 'engime_no'                 => $res['engime_no'],
                        // 'chasisi_no'                => $res['chasisi_no'],
                        // 'vehicle_no'                => $res['vehicle_no'],
                        // 'color'                     => $res['color'],
                        // 'odometer_reading'          => $res['odometer_reading'],
                        // 'is_the_vehicle_total_loss' => $res['is_the_vehicle_total_loss'],
                        // 'condition_of_vehicle'      => $res['condition_of_vehicle'],    
                        // 'place_of_survey'           => $res['place_of_survey'],
                        // 'point_of_impact'           => $res['point_of_impact']
                        // 'details_url' => '/claim/details_with_survey?id=' . $res['id']
                    ],
                    'survey_information' => [
                        // 'garage'            => $res['garage'],
                        // 'eor_value'         => $res['eor_value'],
                        // 'invoice_number'    => $res['invoice_number'],
                        // 'survey_type'       => $res['survey_type'],
                        // 'date_of_survey'    => $res['date_of_survey']
                    ],
                    'estimate_of_repairs' => [
                        'part_detail'   =>  [
                            // 'part_name'     => $res['part_name'],
                            // 'part_number'   => $res['part_number'],
                            // 'part_price'    => $res['part_price'],
                            // 'part_quantity' => $res['part_quantity'],
                            // 'total_price'   => $res['total_price']
                        ],
                        'labour_detail' => [
                            
                        ]
                        // 'estimation_number' => $res['estimation_number'],
                        // 'estimation_date'   => $res['estimation_date'],
                        // 'estimation_value'  => $res['estimation_value'],
                        // 'is_estimation_approved' => $res['is_estimation_approved']
                    ],
                ];
            }

            return new JsonResponse([
                'status' => 'success',
                'data' => $resFormat
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage(), 'message' => 'Claim retrieval failed.'],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}