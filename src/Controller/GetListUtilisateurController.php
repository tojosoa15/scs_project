<?php

namespace App\Controller;

use App\Repository\UsersRepository;
use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class GetListUtilisateurController extends AbstractController
{
    public function __construct(private Connection $connection) {}

    public function __invoke(Request $request, UsersRepository $usersStory) : JsonResponse
    {
        $query = $request->query->all(); 

        $account = $usersStory->getListUsers($query);

        if (!$account) {
            return new JsonResponse(
                ['error' => 'Aucun compte trouvé'],
                JsonResponse::HTTP_NOT_FOUND
            );
        }

        return new JsonResponse($account);
    }
}
