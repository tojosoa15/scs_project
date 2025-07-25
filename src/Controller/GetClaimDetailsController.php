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

        if (empty($params['claimNo']) && empty($params['email'])) {
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
                'p_claim_number'    => $params['claimNo'],
                'p_email'           => $params['email']
            ]);

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
                            'vat_labour'            => $res['vat_labour'],
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

    /**
     * Renseignement verification surveyor
     * 
     * @param $request
     */
    public function surveyorReport(Request $request): JsonResponse 
    {
        $recentStep = '';
        $data       = (array)json_decode($request->getContent(), true);

        $params = [
            'claimsNo'      => $data['claimsNo'],
            'surveyorId'    => $data['surveyorId'],
            'status'        => $data['status'] ?? false,
            'currentStep'   => $data['currentStep'],
            'json_data'     => json_encode($data)
        ];
        
        $requiredFields = ['claimsNo', 'surveyorId', 'currentStep'];
        
        foreach ($requiredFields as $field) {

            if (empty($data[$field]) && $data[$field] !== false && $data[$field] !== 0) {
                return new JsonResponse(
                    [
                        'status'    => 'error',
                        'code'      => JsonResponse::HTTP_BAD_REQUEST,
                        'message'   => "'{$field}' parameters is required"
                    ],
                    JsonResponse::HTTP_BAD_REQUEST
                );
            }
        }

        // Validation champs obligatoires etape 1
        if ($data['currentStep'] === 'step_1') {
            $requiredVehicleInformation = [
                'make', 'model', 'cc', 'fuelType', 'transmission', 'engimeNo',
                'chasisiNo', 'vehicleNo', 'color', 'odometerReading',
                'isTheVehicleTotalLoss', 'conditionOfVehicle',
                'placeOfSurvey', 'pointOfImpact'
            ];

            foreach ($requiredVehicleInformation as $field) {
                if (empty($data[$field])) {
                    return new JsonResponse(
                        [
                            'status'  => 'error',
                            'code'    => JsonResponse::HTTP_BAD_REQUEST,
                            'message' => "The '{$field}' field is required for step 1."
                        ],
                        JsonResponse::HTTP_BAD_REQUEST
                    );
                }
            }

            $recentStep = 'Vehicle information';
        }

        // Validation champs obligatoires etape 2
        if ($data['currentStep'] === 'step_2') {
            $requiredSurveyInformation = [
                'garage', 'garageAddress', 'garageContactNumber', 'eorValue', 'invoiceNumber', 'surveyType',
                'dateOfSurvey', 'timeOfSurvey', 'preAccidentValeur', 'showroomPrice','wrechValue', 'excessApplicable'
            ];

            foreach ($requiredSurveyInformation as $field) {
                if (empty($data[$field])) {
                    return new JsonResponse(
                        [
                            'status'  => 'error',
                            'code'    => JsonResponse::HTTP_BAD_REQUEST,
                            'message' => "The '{$field}' field is required for step 2."
                        ],
                        JsonResponse::HTTP_BAD_REQUEST
                    );
                }
            }

            $recentStep = 'Survey information';
        }

        // Validation champs obligatoires etape 3
        if ($data['currentStep'] === 'step_3') {
            $requiredEstimateFields = ['currentEditor', 'remarks', 'parts', 'labours'];

            foreach ($requiredEstimateFields as $field) {
                if (empty($data[$field])) {
                    return new JsonResponse(
                        [
                            'status'  => 'error',
                            'code'    => JsonResponse::HTTP_BAD_REQUEST,
                            'message' => "The '{$field}' field is required for step 3."
                        ],
                        JsonResponse::HTTP_BAD_REQUEST
                    );
                }
            }

            // Valider que parts et labours sont des tableaux
            if (!is_array($data['parts']) || !is_array($data['labours'])) {
                return new JsonResponse(
                    ['status' => 'error', 'message' => 'The “parts” and “labours” fields must be tables.'],
                    JsonResponse::HTTP_BAD_REQUEST
                );
            }

            $recentStep = 'Estimate of repair';
        }

        try {
            $this->claimDetailsService->callSpVerificationProcessSurveyor([
                'p_claim_number'    => $params['claimNumber'],
                'p_surveyor_id'     => $params['surveyorId'],
                'p_status'          => $params['status'],
                'p_current_step'    => $params['currentStep'],
                'p_json_data'       => $params['json_data']
            ]);

            return new JsonResponse([
                'status' => [
                    'status'    => 'success',
                    'code'      => 200,
                    'message'   => "{$recentStep} successfully completed",
                ]
            ]);

        } catch (\Throwable $th) {
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

    /**
     * Retourne le résumé des rapports vérificateurs
     * 
     * @param $request
     */
    public function reportSummary(Request $request): JsonResponse
    {
        $resFormat = [];

        $params = $request->query->all();

        if (empty($params['claimNo']) && empty($params['email'])) {
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
            $results = $this->claimDetailsService->callGetSummary([
                'p_claim_number'    => $params['claimNo'],
                'p_email'           => $params['email']
            ]);

            foreach ($results as $res) {
                $resFormat = [
                    'claim_number'  => $res['claim_number'],
                    'status_name'   => $res['status_name'],
                    'general_informatin' => [
                        'name'                      => $res['name'],
                        'make'                      => $res['make'],
                        'model'                     => $res['model'],
                        'condition_of_vehicle'      => $res['condition_of_vehicle'],    
                        'chasisi_no'                => $res['chasisi_no'],
                        'point_of_impact'           => $res['point_of_impact'],
                        'place_of_survey'           => $res['place_of_survey'],
                        'is_the_vehicle_total_loss' => $res['is_the_vehicle_total_loss']
                    ],
                    'survey_information' => [
                        'invoice_number'        => $res['invoice_number'],
                        'survey_type'           => $res['survey_type'],
                        'eor_value'             => $res['eor_value'],
                        'date_of_survey'        => $res['date_of_survey']
                    ],
                    'rapaire_estimate' => [
                        'part_details'   =>  [
                            'cost_part'     => $res['cost_part'],
                            'discount_part' => $res['discount_part'],
                            'vat_part'      => $res['vat_part'],
                            'part_total'    => $res['part_total']
                        ],
                        'labour_details' => [
                            'hourly_const_labour'   => $res['hourly_const_labour'],
                            'discount_labour'       => $res['discount_labour'],
                            'vat_labour'            => $res['vat_labour'],
                            'labour_total'          => $res['labour_total']
                        ],
                        'grand_tatal'   => [
                            'cost_total'        => $res['cost_total'],//(float)$res['cost_part'] + (float)$res['hourly_const_labour'],
                            'discount_total'    => $res['discount_total'],//(float)$res['discount_part'] + (float)$res['discount_labour'],
                            'vat_total'         => $res['vat_total'],//(float)$res['vat_part'] + (float)$res['vat_labour'],
                            'total'             => $res['total']//(float)$res['part_total'] + (float)$res['labour_total']
                        ],
                    ]
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful report summary',
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