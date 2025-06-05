<?php
namespace App\Controller;

use App\Repository\UsersRepository;
use Doctrine\DBAL\Connection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimsByUserController extends AbstractController
{
    public function __construct(private Connection $connection) {}

    public function __invoke(Request $request, UsersRepository $usersStory)
    {
        $query = $request->query->all();

        if (empty($query['email'])) {
            return new JsonResponse(
                ['error' => 'Email parameter is required'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // Préparation des paramètres avec des valeurs par défaut
        $params = [
            'email' => $query['email'],
            'f_status' => $query['f_status'] ?? null,
            'search_name' => $query['search_name'] ?? null,
            'sort_by' => $query['sort_by'] ?? 'date',
            'page' => (int)($query['page'] ?? 1),
            'page_size' => (int)($query['page_size'] ?? 10),
            'search_num' => $query['search_num'] ?? null,
            'search_reg_num' => $query['search_reg_num'] ?? null,
            'search_phone' => $query['search_phone'] ?? null
        ];

        try {
            // Solution alternative pour SQL Server
            $sql = "EXEC [dbo].[GetListByUser] 
                @email = ?,
                @f_status = ?,
                @search_name = ?,
                @sort_by = ?,
                @page = ?,
                @page_size = ?,
                @search_num = ?,
                @search_reg_num = ?,
                @search_phone = ?";

            // Utilisation de executeQuery avec les paramètres dans l'ordre
            $results = $this->connection->executeQuery($sql, [
                $params['email'],
                $params['f_status'],
                $params['search_name'],
                $params['sort_by'],
                $params['page'],
                $params['page_size'],
                $params['search_num'],
                $params['search_reg_num'],
                $params['search_phone']
            ], [
                \PDO::PARAM_STR,
                \PDO::PARAM_STR,
                \PDO::PARAM_STR,
                \PDO::PARAM_STR,
                \PDO::PARAM_INT,
                \PDO::PARAM_INT,
                \PDO::PARAM_STR,
                \PDO::PARAM_STR,
                \PDO::PARAM_STR
            ])->fetchOne();
            
            $jsonData = json_decode($results, true);
            return new JsonResponse(['status' => 'success', 'data' => $jsonData], JsonResponse::HTTP_OK);

            // return new JsonResponse(
            //     $results ?: ['message' => 'No claims found for this user'],
            //     JsonResponse::HTTP_OK
            // );

        } catch (\Exception $e) {
            return new JsonResponse(
                // ['error' => 'Database error: ' . $e->getMessage()],
                ['status' => 'error', 'error_message' => 'Database error: ' . $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}