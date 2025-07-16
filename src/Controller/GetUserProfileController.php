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
use Symfony\Component\Security\Core\User\UserInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Exception\JWTDecodeFailureException;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;

#[AsController]
class GetUserProfileController extends AbstractController
{
    
    public function __construct(
        private ClaimUserDbService $claimUserDbService,
        private EmailService $emailService,
        private UserPasswordHasherInterface $passwordHashe,
        private JWTTokenManagerInterface $jwtManager,
        private JWTEncoderInterface $jwtDecoder
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

        if (empty($params['email'])) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Email parameter is required.',
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
             $data = $this->claimUserDbService->callForgotPassword([
                'p_email_address' => $params['email']
            ]);

            // Email n'existe pas
            if (empty($data) || empty($data[0]['email_address'])) {
                return new JsonResponse(
                    [
                        'status'    => 'error',
                        'cod'       => JsonResponse::HTTP_NOT_FOUND,
                        'message'   => 'Email not found.'
                    ], JsonResponse::HTTP_NOT_FOUND);
            }

            $results = $this->claimUserDbService->callGetUserProfile([
                'p_email_address' => $params['email']
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
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful user information.',
                'data'      => $formatResult
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
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
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Role parameter is required.',
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $results = $this->claimUserDbService->callGetUserByRole([
                'role_id' => $params['role_id']
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => '',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
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
        // $params = $request->query->all();
        $params = (array)json_decode($request->getContent(), true);

        if (empty($params['email'])) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Email parameter is required.',
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
                $results = $this->claimUserDbService->callUpdateAdminSetting([
                    'p_email_address'         => $params['email'],
                    'p_primary_contact_name'  => $params['primaryContactName'],
                    'p_primary_contact_post'  => $params['primaryContactPost'],
                    'p_notification'          => $params['notification'],
                ]);

                return new JsonResponse([
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_OK,
                    'message'   => 'Successful Administrative settings modification.',
                    'data'      => $results
                ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Mise à jour du password de l'utilisateur
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function updateUserPassword(Request $request) : JsonResponse {
        // $params = $request->query->all();
        $params = (array)json_decode($request->getContent(), true);

        if (empty($params['email'])) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Email parameter is required'
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $plainPassword = $params['newPassword'];

        // Validation simple (à remplacer par validator si besoin)
        if (strlen($plainPassword) < 8 || !preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$/', $plainPassword)) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Your password should: Have at least 1 uppercase letter, Have at least 1 number,  .'
                ],
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
                'p_email_address' => $params['email'],
                'p_new_password'  => $hashedPassword
            ]);

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful password change.',
                'data'      => $results
            ], JsonResponse::HTTP_OK);

        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
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
        $params = (array)json_decode($request->getContent(), true);
        $email = $params['email'] ?? null;
        
        if (empty($email)) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Email parameter is required'
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
        
        try {
            $data = $this->claimUserDbService->callForgotPassword([
                'p_email_address' => $email
            ]);

            // Email n'existe pas
            if (empty($data) || empty($data[0]['email_address'])) {
                return new JsonResponse(
                    [
                        'status'    => 'error',
                        'cod'       => JsonResponse::HTTP_NOT_FOUND,
                        'message'   => 'Email not found.'
                    ], JsonResponse::HTTP_NOT_FOUND);
            }

            // Envoyer email de réinitialisation de mot de passe
                // Générer un token (simple exemple)
                // $token = bin2hex(random_bytes(32));
                // Création d'un utilisateur temporaire compatible JWT
            $user = new class(
                $data[0]['email_address'],
                $data[0]['business_name'],
            ) implements UserInterface {
                private string $email;
                private string $businessName;

                public function __construct(
                    string $email
                    , string $businessName
                ) {
                    $this->email = $email;
                    $this->businessName = $businessName;
                }

                public function getUserIdentifier(): string {
                    return $this->email;
                }

                public function getRoles(): array {
                    return ['test'];
                }

                public function getBusinessName(): ?string
                {
                    return $this->businessName;
                }

                public function getPassword(): ?string {
                    return null;
                }

                public function getSalt(): ?string {
                    return null;
                }

                public function getUsername(): string {
                    return $this->email;
                }

                public function eraseCredentials(): void {}
            };
                
            // // Génére le token JWT avec expiration 15 min
            $payload = [
                // 'email' => $email,
                'exp' => (new \DateTime('+15 minutes'))->getTimestamp()
            ];
    
            $token = $this->jwtManager->createFromPayload($user, $payload);

            $url = $request->headers->get('Origin');

            $resetLink = sprintf('%s/auth/reset-password?email=%s&token=%s', $url, $email, $token);

            $this->emailService->sendResetPasswordEmail($email, $resetLink);
            

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Reset email sent.'
            ], JsonResponse::HTTP_OK);
        
        } catch (\Exception $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
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

    /**
     * Verifier expiratoin token avant reset password
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function verifyResetPassword(Request $request) : JsonResponse {
        // $token = $request->query->get('token');
        $query = (array)json_decode($request->getContent(), true);
        
        $token =  $query['token'];
        
        if (!$token) {
            return new JsonResponse(['error' => 'Token manquant.'], 400);
        }

        try {
            $data = $this->jwtDecoder->decode($token);

            // return new JsonResponse(['status' => 'ok', 'email' => $data]);

            // Vérification expiration manuelle (facultatif, déjà gérée en interne)
            if (isset($data['exp']) && time() > $data['exp']) {
                return new JsonResponse(['error' => 'Token expiré.'], 403);
            }

            // À ce stade, le token est OK, tu peux continuer...
            // $email = $data['email'];
            // $userId = $data['id'];
            // $businessName = $data['business_name'];

            return new JsonResponse([
                'status' => 'ok', 
                'code' => 200,
                'token' => $token
            ]);

        } catch (JWTDecodeFailureException $e) {
            return new JsonResponse(
                [
                    'status'    => 'error',
                    'code'      => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                    'message'   => $e->getMessage()
                ],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}