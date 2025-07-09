<?php

namespace App\Controller;

use App\Entity\ClaimUser\AccountInformations;
use App\Service\ClaimUserDbService;
use App\Service\EmailService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

#[AsController]
class GetUserProfileController extends AbstractController
{
    public function __construct(
        private ClaimUserDbService $claimUserDbService,
        private EmailService $emailService,
        private UserPasswordHasherInterface $passwordHashe
    ) {}

    /**
     * Get user profile information by email address.
     *
     * @param Request $request
     * @return JsonResponse
     */
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
                    'account_information'  => [
                        'business_name'                 => $res['business_name'],
                        'business_registration_number'  => $res['business_registration_number'],
                        'business_address'              => $res['business_address'],
                        'city'                          => $res['city'],
                        'postal_code'                   => $res['postal_code'],
                        'phone_number'                  => $res['phone_number'],
                        'email_address'                 => $res['email_address'],
                        'website'                       => $res['website']
                    ],
                    'financial_information' => [
                        'vat_number'                    => $res['vat_number'],
                        'tax_identification_number'     => $res['tax_identification_number'],
                        'bank_name'                     => $res['bank_name'],
                        'bank_account_number'           => $res['bank_account_number'],
                        'swift_code'                    => $res['swift_code']
                    ],
                    'administrative_settings' => [
                        'primary_contact_name'      => $res['primary_contact_name'],
                        'primary_contact_post'      => $res['primary_contact_post'],
                        'notification'              => $res['notification'],
                        'administrative_updated_at' => $res['administrative_updated_at']
                    ],
                    'security_settings' => [
                        'password'      => $res['password'],
                        'backup_email'  => $res['backup_email']
                    ],
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'data'      => $formatResult
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage(), 'message' => 'Profile retrieval failed.'],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Utilisateur par role
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserByRole(Request $request) : JsonResponse {
          $params   = $request->query->all();

        if (empty($params['role_id'])) {
            return new JsonResponse(
                ['error' => 'Id parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimUserDbService->callGetUserByRole([
                'role_id' => $params['role_id']
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /** 
     * Mise à jour du site web de l'utilisateur
     * 
     *  @param Request $request
     *  @return JsonResponse
     */
    public function updateAdminSetting(Request $request) : JsonResponse {
        $params = $request->query->all();

      if (empty($params['p_email_address'])) {
          return new JsonResponse(
              ['error' => 'p_email_address parameter is required'],
              JsonResponse::HTTP_BAD_REQUEST
          );
      }

      try {
            $results = $this->claimUserDbService->callUpdateAdminSetting([
                'p_email_address'         => $params['p_email_address'],
                'p_primary_contact_name'  => $params['p_primary_contact_name'],
                'p_primary_contact_post'  => $params['p_primary_contact_post'],
                'p_notification'          => $params['p_notification'],
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

      } catch (\Exception $e) {
          return new JsonResponse(
              ['error' => $e->getMessage()],
              JsonResponse::HTTP_INTERNAL_SERVER_ERROR
          );
      }
    }

    /**
     * Mise à jour du site web de l'utilisateur
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function updateUserPassword(Request $request) : JsonResponse {
        // $params = $request->query->all();
        $params = (array)json_decode($request->getContent(), true);

        if (empty($params['p_email_address'])) {
            return new JsonResponse(
                ['error' => 'p_email_address parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $plainPassword = $params['p_new_password'];

        // Validation simple (à remplacer par validator si besoin)
        if (strlen($plainPassword) < 8 || !preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$/', $plainPassword)) {
            return new JsonResponse(
                ['error' => 'Mot de passe invalide. Il doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // Crée un user temporaire (obligatoire pour le hashPassword)
        $user = new AccountInformations();
        $user->setPlainPassword($plainPassword);

        // Hashe le mot de passe
        $hashedPassword = $this->passwordHashe->hashPassword($user, $plainPassword);

        try {
            $results = $this->claimUserDbService->callUpdateUserPassword([
                'p_email_address' => $params['p_email_address'],
                'p_new_password'  => $hashedPassword
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Test existance mail pour la réinitialisation du mot de passe oublié
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function forgotPassword(Request $request) : JsonResponse {
        $params = $request->query->all();

        
        if (empty($params['p_email_address'])) {
            return new JsonResponse(
                ['error' => 'p_email_address parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
        
        try {
            $data = $this->claimUserDbService->callForgotPassword([
                'p_email_address' => $params['p_email_address']
            ]);

            // Email n'existe pas
            if (empty($data[0]['OK'])) {
                return new JsonResponse(['error' => 'Email introuvable.'], 
                    JsonResponse::HTTP_NOT_FOUND
                );
            }

            // Envoyer email de réinitialisation de mot de passe
            if (!empty($data[0]['OK']) && $data[0]['OK'] === 'OK') {
                // Générer un token (simple exemple)
                $token = bin2hex(random_bytes(32));

                // Génère le lien
                $resetLink = sprintf('http://localhost:8000/api/auth/reset-password/%s', $token);

                $this->emailService->sendResetPasswordEmail($params['p_email_address'], $resetLink);
                

                return new JsonResponse([
                    'status'    => 'success',
                    'message' => 'Email de réinitialisation envoyé.'
                ], JsonResponse::HTTP_OK);
            } 


        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Authentification de l'utilisateur
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function authentification(Request $request) : JsonResponse {
        $params = (array)json_decode($request->getContent(), true);
        
        if (empty($params['p_email_address']) && empty($params['p_password'])) {
            return new JsonResponse(
                ['error' => 'p_email_address et p_password parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
        
        try {
            $results = $this->claimUserDbService->callAuthentification([
                'p_email_address'   => $params['p_email_address'],
                'p_password'        => $params['p_password'],
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}