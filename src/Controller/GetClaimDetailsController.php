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

        if (empty($params['claim_number']) && empty($params['email'])) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Claim Number and email parameters is required'
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimDetailsService->callGetClaimDetails([
                'p_claim_number'    => $params['claim_number'],
                'p_email'           => $params['email']
            ]);

            // return new JsonResponse($results);

            foreach ($results as $res) {
                $resFormat = [
                    'claim_number'  => $res['claim_number'],
                    'status_name'   => $res['status_name'],
                    'vehicle_informatin' => [
                        'make'                      => $res['make'],
                        'model'                     => $res['model'],
                        'cc'                        => $res['cc'],
                        'fuel_type'                 => $res['fuel_type'],
                        'transmission'              => $res['transmission'],
                        'engime_no'                 => $res['engime_no'],
                        'chasisi_no'                => $res['chasisi_no'],
                        'vehicle_no'                => $res['vehicle_no'],
                        'color'                     => $res['color'],
                        'odometer_reading'          => $res['odometer_reading'],
                        'is_the_vehicle_total_loss' => $res['is_the_vehicle_total_loss'],
                        'condition_of_vehicle'      => $res['condition_of_vehicle'],    
                        'place_of_survey'           => $res['place_of_survey'],
                        'point_of_impact'           => $res['point_of_impact']
                        // 'details_url' => '/claim/details_with_survey?id=' . $res['id']
                    ],
                    'survey_information' => [
                        'garage'                => $res['garage'],
                        'garage_address'        => $res['garage_address'],
                        'garage_contact_number' => $res['garage_contact_number'],
                        'eor_value'             => $res['eor_value'],
                        'invoice_number'        => $res['invoice_number'],
                        'survey_type'           => $res['survey_type'],
                        'date_of_survey'        => $res['date_of_survey']
                    ],
                    'estimate_of_repairs' => [
                        'part_detail'   =>  [
                            'part_name'     => $res['part_name'],
                            'quantity'      => $res['quantity'],
                            'supplier'      => $res['supplier'],
                            'quality'       => $res['quality'],
                            'cost_part'     => $res['cost_part'],
                            'discount_part' => $res['discount_part'],
                            'vat_part'      => $res['vat_part'],
                            'part_total'    => $res['part_total']
                        ],
                        'labour_detail' => [
                            'eor_or_surveyor'       => $res['eor_or_surveyor'],
                            'activity'              => $res['activity'],
                            'number_of_hours'       => $res['number_of_hours'],
                            'hourly_const_labour'   => $res['hourly_const_labour'],
                            'discount_labour'       => $res['discount_labour'],
                            'vat_part'              => $res['vat_part'],
                            'labour_total'          => $res['labour_total']
                        ],
                        'remarks'   => $res['remarks']
                    ]
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful Claim details',
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