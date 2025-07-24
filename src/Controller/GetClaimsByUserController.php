<?php

namespace App\Controller;

use App\Entity\ClaimUser\Claims;
use App\Repository\ClaimRepository;
use App\Service\ClaimUserDbService;
use App\Service\EmailValidatorService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetClaimsByUserController extends AbstractController
{
    public function __construct(
        private ClaimUserDbService $claimUserDbService,
        private EntityManagerInterface $em,
        private ClaimRepository $claimRepository,
        private EmailValidatorService $emailValidator
    ) {}

    /**
     * Liste claim d'un utilisateur
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function __invoke(Request $request): JsonResponse
    {
        $params = $request->query->all();

        // Liste des claims par utilisateurs
        if (!empty($params['email'])) {
              try {
                $results = $this->claimUserDbService->callGetListByUser([
                    'p_email'           => $params['email'],
                    'p_status'          => $params['status'] ?? null,
                    'p_search_name'     => $query['search_name'] ?? null,
                    'p_sort_by'         => $query['sort_by'] ?? 'date',
                    'p_page'            => (int)($query['page'] ?? 1),
                    'p_page_size'       => (int)($query['page_size'] ?? 10),
                    'p_search_num'      => $query['search_num'] ?? null,
                    'p_search_reg_num'  => $query['search_reg_num'] ?? null,
                    'p_search_phone'    => $query['search_phone'] ?? null
                ]);
    
                return new JsonResponse([
                    'status'    => 'success',
                    'code'      => JsonResponse::HTTP_OK,
                    'message'   => 'Successful claim list.',
                    'data'      => $results
                ], JsonResponse::HTTP_OK);
    
            } catch (\Exception $e) {
                return new JsonResponse(
                    [
                        'status' =>  'error',
                        'code'  => JsonResponse::HTTP_INTERNAL_SERVER_ERROR,
                        'message' => $e->getMessage()
                    ],
                    JsonResponse::HTTP_INTERNAL_SERVER_ERROR
                );
            }
        } else {
            try {
                $claims = $this->claimUserDbService->callGetAllClaims([
                    'page'      => (int)($query['page'] ?? 1),
                    'page_size' => (int)($query['page_size'] ?? 10),
                ]);
                
                return new JsonResponse([
                    'status'    => 'success',
                    'code'      => JsonResponse::HTTP_OK,
                    'message'   => 'Successful claim list.',
                    'data'      => $claims
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

    }

    /**
     * Cards statistique
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function getCardStats(Request $request): JsonResponse
    {
        $params = $request->query->all();
        $email  = $params['email'];

        if (empty($email) || !$this->emailValidator->isValid($email)) {
            return new JsonResponse(
                [
                    'status'    => 'erreur',
                    'code'      => JsonResponse::HTTP_BAD_REQUEST,
                    'message'   => 'Email parameters are required or invalide'
                ],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        try {
            $cardsStats = $this->claimUserDbService->callGetUserClaimStats([
                'p_email'      => $email
            ]);
            
            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Cards stats.',
                'data'      => $cardsStats
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
}