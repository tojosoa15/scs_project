<?php
namespace App\Controller;

use App\Dto\AuthInput;
use Doctrine\DBAL\Connection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;


#[AsController]
class AuthController extends AbstractController
{
   public function __construct(private Connection $conn) {}

    public function login(AuthInput $authInput, Request $request): JsonResponse
    {
        $data       = json_decode($request->getContent(), true);
 
        $login      = $data['login'] ?? null;
        $password   = $data['password'] ?? null;

        if (!$login || !$password) {
            return new JsonResponse(['error' => 'Login and password required'], 400);
        }

        $result = $this->conn->executeQuery(
            "EXEC [dbo].[Authentification] @Login = ?, @Password = ?",
            [$login, $password]
        )->fetchAssociative(); // Changed from fetchOne()

        return new JsonResponse([$result]);
    }
    
    public function logout(): void
    {
        // Le système de logout de LexikJWT s'occupe de tout
    }
}