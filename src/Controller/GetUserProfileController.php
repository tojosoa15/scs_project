<?php

namespace App\Controller;

use App\Service\ClaimUserDbService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetUserProfileController extends AbstractController
{
    public function __construct(private ClaimUserDbService $claimUserDbService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $formatResult   = [];
        $params         = $request->query->all();

        if (empty($params['p_email_address'])) {
            return new JsonResponse(
                ['error' => 'Email parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimUserDbService->callGetUserProfile([
                'p_email_address' => $params['p_email_address']
            ]);

            foreach ($results as $res) {
                $formatResult = [
                    'account_informations'  => [
                        'business_name'                 => $res['business_name'],
                        'business_registration_number'  => $res['business_registration_number'],
                        'business_address'              => $res['business_address'],
                        'city'                          => $res['city'],
                        'postal_code'                   => $res['postal_code'],
                        'phone_number'                  => $res['phone_number'],
                        'email_address'                 => $res['email_address'],
                        'website'                       => $res['website']
                    ],
                    'financial_informations' => [
                        'vat_number'                    => $res['vat_number'],
                        'tax_identification_number'     => $res['tax_identification_number'],
                        'bank_name'                     => $res['bank_name'],
                        'bank_account_number'           => $res['bank_account_number'],
                        'swift_code'                    => $res['swift_code']
                    ],
                    'administrative_setting' => [
                        'primary_contact_name'      => $res['primary_contact_name'],
                        'primary_contact_post'      => $res['primary_contact_post'],
                        'notification'              => $res['notification'],
                        'administrative_updated_at' => $res['administrative_updated_at']
                    ]
                ];
            }

            return new JsonResponse($formatResult);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}