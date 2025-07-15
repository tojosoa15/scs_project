<?php

namespace App\Controller\Auth;

use App\Entity\Surveyor\RefreshTokens;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Security\Core\User\UserProviderInterface;

class TokenRefreshController
{
    private EntityManagerInterface $em;
    private JWTTokenManagerInterface $jwtManager;
    private UserProviderInterface $userProvider;

    public function __construct(
        EntityManagerInterface $em,
        JWTTokenManagerInterface $jwtManager,
        UserProviderInterface $userProvider
    ) {
        $this->em = $em;
        $this->jwtManager = $jwtManager;
        $this->userProvider = $userProvider;
    }

    public function __invoke(Request $request): JsonResponse
    {
        $data = $request->toArray();
        $refreshToken = $data['refresh_tokens'] ?? null;

        if (!$refreshToken) {
            return new JsonResponse(['message' => 'Paramètre `refresh_tokens` manquant.'], 401);
        }

        $refreshTokenObj = $this->em->getRepository(RefreshTokens::class)->find($refreshToken);

        if (!$refreshTokenObj || !$refreshTokenObj->isValid()) {
            return new JsonResponse(['message' => 'Invalid or expired refresh token'], 401);
        }

        $user = $this->userProvider->loadUserByIdentifier($refreshTokenObj->getUsername());

        $accessToken = $this->jwtManager->create($user);

        return new JsonResponse([
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
        ]);
    }
}