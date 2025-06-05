<?php

namespace App\Controller;

use App\Entity\AdditionalLabourDetails;
use App\Entity\ConditionOfVechicle;
use App\Entity\EstimateOfRepairs;
use App\Entity\LabourDetails;
use App\Entity\PartDetails;
use App\Entity\SurveyInformations;
use App\Entity\VehicleInformations;
use App\Entity\Verifications;
use App\Repository\ConditionOfVechicleRepository;
use App\Repository\VerificationsRepository;
use App\Repository\VerificationsDraftRepository;
use Doctrine\DBAL\Connection;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;


final class VerificationSurveyorController extends AbstractController
{
    public function __construct(
        private Connection $connection,
        private EntityManagerInterface $em,
    ) {}

    public function verificationProcessSurveyor(Request $request, VerificationsRepository $verificationsRepository,) : JsonResponse 
    {
        $message        = "";
        $datas          = (array)json_decode($request->getContent(), true);

        $claimId        = $datas['claimsId'];
        $userId         = $datas['userId'];
        $currentStep    = $datas['currentStep'];

        switch ($currentStep) {
            case 'step_1':
                // Ajout verification
                $verification   = new Verifications();
                $verification->setClaimsId($claimId);
                $verification->setUserId($userId);
                $verification->setIsSubmitted($datas['isSubmitted']);
                $verification->setCurrentStep($currentStep);
                $this->em->persist($verification);
                $this->em->flush();

                // Ajout vehicle information
                $this->addVehicleInformation($datas, $verification);

                $message = "Véhicule information ajouté avec succès";
                break;

            case 'step_2':
                $verification = $verificationsRepository->findIdByClaimAndUser($claimId, $userId);

                // Ajout survey information
                $this->addSurveyInformation($datas, $verification);

                $message = "Survey information ajouté avec succès";
                break;

            case 'step_3':
                $verification = $verificationsRepository->findIdByClaimAndUser($claimId, $userId);

                // Ajout pièce et main d'oeuvre
                $this->addPartDetails($datas, $verification);

                $message = "Pièces et main d'oeuvre ajoutés avec succès";
                break;
            
            case 'step_4':
                // Mise à jour dans vérification
                $verification = $verificationsRepository->findIdByClaimAndUser($claimId, $userId);

                if ($verification instanceof Verifications) {
                    $verification->setCurrentStep($datas['currentStep']);
                    $verification->setIsSubmitted($datas['isSubmitted']);
                    $this->em->persist($verification);
                }
                $this->em->flush();

                $message = "Soumise avec succès";
                break;
        }

        return new JsonResponse([
            'status' => [
                'code'      => 200,
                'success'   => true,
                'message'   => $message,
                'data'      => $verification->getId(),
                'errorCode' => null
            ]
        ], Response::HTTP_OK);
    }

    /**
     * Fonciton pour ajouter les information vehicule
     * $datas les inputs das le body
     * $verification réf entinty vereification
     */
    public function addVehicleInformation($datas, $verification)
    {
        // Etape 1, ajout vehicule information
        $estimateOfRepairs = new EstimateOfRepairs();
        // $estimateOfRepairs->setClaims($datas['claimsId']);
        $estimateOfRepairs->setVerifications($verification);
        $estimateOfRepairs->setRemarks($datas['remarks']);
        $this->em->persist($estimateOfRepairs);
        $this->em->flush();

        $vehicleInformation   = new VehicleInformations();
        $vehicleInformation->setEstimateOfRepairs($estimateOfRepairs);
        $vehicleInformation->setMake($datas['make']);
        $vehicleInformation->setModel($datas['model']);
        $vehicleInformation->setCc($datas['cc']);
        $vehicleInformation->setFuelType($datas['fuelType']);
        $vehicleInformation->setTransmission($datas['transmission']);
        $vehicleInformation->setEngimeNumber($datas['engimeNo']);
        $vehicleInformation->setChasisiNumber($datas['chasisiNo']);
        $vehicleInformation->setVehicleNumber($datas['vehicleNo']);
        $vehicleInformation->setColor($datas['color']);
        $vehicleInformation->setOdometerReading($datas['odometerReading']);
        $vehicleInformation->setIsTheVehicleTotalLoss($datas['isTheVehicleTotalLoss']);
        // $vehicleInformation->setConditionOfVechicle($datas['conditionOfVechicleId']);
        $vehicleInformation->setPlaceOfSurvey($datas['placeOfSurvey']);
        $vehicleInformation->setPointOfImpact($datas['pointOfImpact']);
        $this->em->persist($vehicleInformation);
        $this->em->flush();
    }

    /**
     * Fonciton pour ajouter les informations de l'enquête
     * $datas les inputs das le body
     * $verification réf entinty vereification
     */
    public function addSurveyInformation($datas, $verification) 
    {
        $date = \DateTime::createFromFormat('Y-m-d', $datas['dateOfSurvey']);
        $time = \DateTime::createFromFormat('H:i:s', $datas['timeOfsurvey']);

        $surveyInformation   = new SurveyInformations();
        // $surveyInformation->setVerifications($verification);
        $surveyInformation->setGarage($datas['garage']);
        $surveyInformation->setGarageAddress($datas['garageAddress']);
        $surveyInformation->setGarageContactNumber($datas['garageContactNo']);
        $surveyInformation->setEorValue($datas['eorValue']);
        $surveyInformation->setInvoiceNumber($datas['invoiceNo']);
        $surveyInformation->setSurveyType($datas['surveyType']);
        $surveyInformation->setDateOfSurvey($date);
        $surveyInformation->setTimeOfSurvey($time);
        $surveyInformation->setPreAccidentValue($datas['preAccidentvalue']);
        $surveyInformation->setShowroomPrice($datas['showroomPrice']);
        $surveyInformation->setWreckValue($datas['wreckValue']);
        $surveyInformation->setExcessApplicable($datas['excessApplicable']);

        return $surveyInformation;
        $this->em->persist($surveyInformation);

        // Mettre à jour le currentStep dans Verifications
        if ($verification instanceof Verifications) {
            $verification->setCurrentStep($datas['currentStep']);
            $this->em->persist($verification);
        }

        // Exécuter un seul flush pour les deux opérations
        $this->em->flush();
    }

    /**
     * Fonciton pour ajouter les pièces et main d'oeuvre nécessaires
     * $datas les inputs das le body
     * $verification réf entinty vereification
     */
    public function addPartDetails($datas, $verification)
    {
        // Récupérer l'estimateOfRepairs lié à la verification
        $estimateOfRepairs = $verification->getEstimateOfRepairs();
   
        if (isset($datas['partLabourDetails'])) {
            foreach ($datas['partLabourDetails'] as $partLabourData) {
                // Ajout part détails
                $partDetail = new PartDetails();
                $partDetail->setPartName($partLabourData['partName']);
                $partDetail->setQuantity($partLabourData['quantity']);
                $partDetail->setSupplier($partLabourData['supplier']);
                $partDetail->setQuality($partLabourData['quality']);
                $partDetail->setCostPart($partLabourData['costPart']);
                $partDetail->setDiscountPart($partLabourData['discountPart']);
                $partDetail->setPartTotal($partLabourData['partTotal']);
                $partDetail->setEstimateOfRepairs($estimateOfRepairs);
                
                $this->em->persist($partDetail);

                // Ajout main d'oeuvre
                $labourDetail = new LabourDetails();
                $labourDetail->setPartDetails($partDetail);
                $labourDetail->setActivity($partLabourData['activity']);
                $labourDetail->setNumberOfHours($partLabourData['numberOfHours']);
                $labourDetail->setHourlyCostLabour($partLabourData['hourlCostLabour']);
                $labourDetail->setDiscountLabour($partLabourData['discountLabour']);
                $labourDetail->setLabourTotal($partLabourData['labourTotal']);

                $this->em->persist($labourDetail);
            }

            //Ajout additional labour
            if (isset($datas['additionalLabourDetails'])) {
                $this->addAdditionalLabourDetails($datas, $estimateOfRepairs);
            }

            // Mettre à jour le currentStep dans Verifications
            if ($verification instanceof Verifications) {
                $verification->setCurrentStep($datas['currentStep']);
                $this->em->persist($verification);
            }
            
            $this->em->flush();
        }
    }

    /**
     * Fonciton pour ajouter des mains d'oeuvre supplemetaires
     * $datas les inputs das le body
     * $verification réf entinty vereification
     */
    public function addAdditionalLabourDetails($datas, $estimateOfRepairs)
    {
        foreach ($datas['additionalLabourDetails'] as $partLabourData) {
            // Ajout part détails
            $additionalLabour = new AdditionalLabourDetails();
            // $additionalLabour->setPartName($partLabourData['partName']);
            // $partDetail->setQuantity($partLabourData['quantity']);
            // $partDetail->setSupplier($partLabourData['supplier']);
            // $partDetail->setQuality($partLabourData['quality']);
            // $partDetail->setCostPart($partLabourData['costPart']);
            // $partDetail->setDiscountPart($partLabourData['discountPart']);
            // $partDetail->setPartTotal($partLabourData['partTotal']);
            // $partDetail->setEstimateOfRepairs($estimateOfRepairs);
            
            $this->em->persist($additionalLabour);
        }
        
        $this->em->flush();
    }

    public function getSummarySurveyor(Request $request, VerificationsDraftRepository $verificationDraft) : JsonResponse
    {
        $result         = [];
        $sumSubTotal    = 0;
        $discountAmount = 0;
        $vat            = 0;
        $query          = $request->query->all();
        
        $summary = $verificationDraft->getSummaryInDraft($query);

        if (!$summary) {
            return new JsonResponse(
                ['error' => 'Aucun résultat trouvé'],
                JsonResponse::HTTP_NOT_FOUND
            );
        }

        foreach ($summary as $value) {
            $date_time_of_survey = ($value['dateOfSurvey'] ? $value['dateOfSurvey']->format('d:M:y') : null);
            // Labour detail
            $sumSubTotal    += $value['labourTotal'] ?? null;
            $discountAmount += $value['discountLabour'] ?? null;
            $vat            += $value['labour_vat'] ?? null;

            // $result_labour = [
            //     'labour_sub_total'         => $sumSubTotal,
            //     'labour_discount_amount'   => $discountAmount, 
            //     'labour_vat'               => $vat, 
            // ];

        //     $result = [
        //        'claim_no' => $value['claim_number'],
        //        'general_information' => [
        //            'name_customer'               => $value['name_customer'] ?? null ?? null,            
        //            'make'                        => $value['make'] ?? null,            
        //            'model'                       => $value['model'] ?? null,            
        //            'chasisi_number'              => $value['chasisiNumber'] ?? null,            
        //            'point_of_impact'             => $value['pointOfImpact'] ?? null,            
        //            'place_of_survey'             => $value['placeOfSurvey'] ?? null,            
        //            'is_the_vehicle_total_loss'   => $value['isTheVehicleTotalLoss'] ?? null            
        //        ],
        //        'survey_information' => [
        //            'invoice_number'         => $value['invoiceNumber'] ?? null,            
        //            'survey_type'            => $value['surveyType'] ?? null,            
        //            'eor_value'              => $value['eorValue'] ?? null,            
        //            'date_time_of_survey'    => $date_time_of_survey
        //        ],
        //        'repaire_estimate' => [
        //             'part' => [
        //                 'part_cost'     => $value['costPart'] ?? null,
        //                 'part_discount' => $value['discountPart'] ?? null,
        //                 'part_vat'      => $value['part_vat'] ?? null,
        //                 'part_total'    => $value['partTotal'] ?? null
        //             ],
        //             'labour' => [
        //                 'lobour_cost'       => $value['hourlyCostLabour'] ?? null,
        //                 'labour_discount'   => $value['discountLabour'] ?? null,
        //                 'labour_vat'        => $value['labour_vat'] ?? null,
        //                 'labour_total'      => $value['labourTotal'] ?? null
        //             ], 
        //             'grand_total' => [
        //                 'part_cost'     =>($value['costPart'] ?? null) + ($value['hourlyCostLabour'] ?? null),
        //                 'part_discount' => ($value['discountPart'] ?? null) + ($value['discountLabour'] ?? null),
        //                 'part_vat'      => ($value['part_vat'] ?? null) + ($value['labour_vat'] ?? null),
        //                 'part_total'    => ($value['partTotal'] ?? null) + ($value['labourTotal'] ?? null),
        //             ]
        //        ]
        //    ];
        }
        array_push($summary, $result);

        return new JsonResponse($summary);
    }

   
}
