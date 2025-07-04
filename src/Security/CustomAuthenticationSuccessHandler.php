<?php

namespace App\Security;

use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTManager;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Http\Authentication\AuthenticationSuccessHandlerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;

class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandlerInterface
{
    private JWTTokenManagerInterface $jwtManager;

    public function __construct(JWTTokenManagerInterface $jwtManager)
    {
        $this->jwtManager = $jwtManager;
    } 

    public function onAuthenticationSuccess(Request $request, TokenInterface $token): Response
    {
        /** @var \App\Entity\ClaimUser\AccountInformations $user */
        $user = $token->getUser();

        // Génére manuellement le JWT
        $jwt = $this->jwtManager->create($user);

        return new JsonResponse([
            'status' => 'success',
            'code' => 200,  
            'message' => 'Authentification réussie.',
            'data' => [
                'accessToken' => $jwt,
                'user' => [
                    'id' => $user->getId(),
                    'email' => $user->getEmailAddress(),
                    'roles' => $user->getRoles(),
                    'business_name' => $user->getBusinessName(),
                ]
            ]
        ]);
    }
}