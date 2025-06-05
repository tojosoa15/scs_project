<?php
namespace App\Controller;

use App\Repository\PayementsRepository;
use App\Service\PayementService;
use DateTime;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Attribute\AsController;

#[AsController]
class ExportListPayementController extends AbstractController
{
    public function __invoke(Request $request, PayementsRepository $payement, PayementService $payementService)
    {
        $query      = $request->query->all();

        // Vérifier l'identifiant utilisateur
        if (!isset($query['userId'])) {
            return new JsonResponse(
                ['error' => 'Identifiant utilisateur obligatoire'],
                JsonResponse::HTTP_BAD_REQUEST // 400
            );
        }

        // Vérifier la date start, date end et le type de l'export
        if (empty($query['startDateSubmited']) || 
            empty($query['endDateSubmited'])
        ) {
            return new JsonResponse(
                ['error' => 'Date start et date end sont obligatoires'],
                JsonResponse::HTTP_BAD_REQUEST // 400
            );
        } 

        // Date start
        $dateStart  = new \DateTime($query['startDateSubmited']);
        $dateStart  = $dateStart->format('Y-m-d');
        // Date end
        $dateEnd  = new \DateTime($query['endDateSubmited']);
        $dateEnd  = $dateEnd->format('Y-m-d');


        if (empty($query['typeExport'])) {
            return new JsonResponse(
                ['error' => 'Type de l\'export obligatoire'],
                JsonResponse::HTTP_BAD_REQUEST // 400
            );
        }

        $payements  = $payement->getListPayementUser($query, $dateStart, $dateEnd);

        if ($query['typeExport'] == 'pdf') {
            return $payementService->generatePdf($payements);
        }

        if ($query['typeExport'] == 'xlsx') {
            return $payementService->generateExcel($payements);
        }

        throw new \Exception('Type d\'export pas renseigné');
    }
}