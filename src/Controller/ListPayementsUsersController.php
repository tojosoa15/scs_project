<?php

namespace App\Controller;

use App\Repository\PayementsRepository;
use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;


final class ListPayementsUsersController extends AbstractController
{
     public function __construct(private Connection $connection) {}

    public function __invoke(Request $request, PayementsRepository $payement) : JsonResponse
    {
        $query      = $request->query->all();       

        $payements  = $payement->getListPayementUser($query);

        foreach ($payements as $key => $paymt) {
            $payements[$key] = [
                'idPaiment'     => $paymt['id'] ?? null,
                'dateSubmitted' => $paymt['dateSubmitted'] ? $paymt['dateSubmitted']->format('Y-M-d') : null,
                'invoiceNum'    => $paymt['invoiceNum'] ?? null,
                'claimNum'      => $paymt['claimNum'] ?? null,
                'claimAmount'   => $paymt['claimAmount'] ?? null,
                'payementDate'  => $paymt['payementDate'] ? $paymt['payementDate']->format('Y-M-d') : null,
                'statusName'    => $paymt['statusName'] ?? null,
            ];
        }

        return new JsonResponse($payements);
    }
}
