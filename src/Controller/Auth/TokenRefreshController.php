<?php

namespace App\Controller\Auth;

use App\Entity\Surveyor\RefreshTokens;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Core\User\UserProviderInterface;

/**
 * @Route("/auth/refresh-token", name="custom_refresh_token", methods={"POST"})
 */
class TokenRefreshController
{
    public function __invoke(
        Request $request,
        EntityManagerInterface $em,
        UserProviderInterface $userProvider,
        JWTTokenManagerInterface $jwtManager
    ): JsonResponse {
        $data = $request->toArray();
        $refreshToken = $data['refresh_token'] ?? null;

        if (!$refreshToken) {
            return new JsonResponse(['message' => 'Missing refresh_token'], 401);
        }

        // Chercher le token en base
        $refreshTokenObj = $em->getRepository(RefreshTokens::class)->find($refreshToken);

        if (!$refreshTokenObj || !$refreshTokenObj->isValid()) {
            return new JsonResponse(['message' => 'Invalid or expired refresh token'], 401);
        }

        // Récupérer l'utilisateur associé au token
        $user = $userProvider->loadUserByIdentifier($refreshTokenObj->getUsername());

        // Générer le nouveau JWT
        $accessToken = $jwtManager->create($user);

        return new JsonResponse([
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
        ]);
    }
}