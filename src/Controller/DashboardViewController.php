<?php

namespace App\Controller;

use App\Entity\ClaimUser\Claims;
use App\Entity\Fund;
use App\Entity\NavFunds;
use Carbon\Carbon;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class DashboardViewController extends AbstractController
{
    public function __construct(
        private EntityManagerInterface $em
    ) {}

    /**
     * Liste nav des funds
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function getAllNavFunds(Request $request): JsonResponse
    {
        $navFundsFormat = [];

        try {
            $navFunds = $this->em->getRepository(NavFunds::class)->findAll();

            foreach ($navFunds as $nav) {
                $navFundsFormat[] = [
                    'id'        => $nav->getId(),
                    'codeName'  => $nav->getCodeName(),
                    'typeNav'   => $nav->getTypeNav(),
                    'value'     => $nav->getValue()
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful list nav of the funds.',
                'data'      => $navFundsFormat
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
    }

    /**
     * Liste funds d'un client
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function getAllFundsByCustomer(Request $request): JsonResponse
    {
        $fundFormat = [];
        $params     = $request->query->all();
        $fundName       = $params['fundName'] ?? null;    
        $period     = $params['period'] ?? null;

        try {
            // Aucun paramètre renseigné -> retourner tout
            if ((empty($fundName) || $fundName === null) && (empty($period) || $period === null)) {
                $funds = $this->em->getRepository(Fund::class)->findAll();
                // Seulement un des deux est renseigné -> erreur
            } elseif ((empty($fundName) || $fundName === null) xor (empty($period) || $period === null)) {
                throw new \InvalidArgumentException("You must fill in both ‘fundName’ and ‘period’.");

            // Les deux sont renseignés -> appliquer le filtre
            } else {
                // calcul de la date de début en fonction de la période
                switch ($period) {
                    case '1M':
                        $startDate = Carbon::now()->subMonth();
                        break;
                    case '3M':
                        $startDate = Carbon::now()->subMonths(3);
                        break;
                    case '6M':
                        $startDate = Carbon::now()->subMonths(6);
                        break;
                    case 'YTD':
                        $startDate = Carbon::now()->startOfYear();
                        break;
                    case '1Y':
                        $startDate = Carbon::now()->subYear();
                        break;
                    case 'ALL':
                    default:
                        $startDate = null; // pas de limite
                }

                // dd($startDate);

                $funds = $this->em->getRepository(Fund::class)
                        ->findByNameAndPeriod($fundName, $startDate);
            }

            foreach ($funds as $f) {
                $fundFormat[] = [
                    'id'            => $f->getId(),
                    'reference'     => $f->getReference(),
                    'fundName'      => $f->getFundName(),
                    'noOfShares'    => $f->getNoOfShares(),
                    'nav'           => $f->getNav(),
                    'totalAmountCcy'=> $f->getTotalAmountCcy(),
                    'fundDate'      => $f->getFundDate() ? $f->getFundDate()->format('Y-m-d') : null
                ];
            }

            return new JsonResponse([
                'status'    => 'success',
                'code'      => JsonResponse::HTTP_OK,
                'message'   => 'Successful list of funds by customer.',
                'data'      => $fundFormat
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