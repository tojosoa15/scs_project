<?php
namespace App\Controller;

use App\Repository\UsersRepository;
use Doctrine\DBAL\Connection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[AsController]
class GetProfilUserController extends AbstractController
{
    public function __construct(private Connection $connection) {}

    public function __invoke(Request $request, UsersRepository $user) : JsonResponse
    {
        $result = [];
        $query  = $request->query->all(); // Récupère tous les paramètres GET

        // Vérifie si ni email ni id n'est fourni
        if (empty($query['email'] ?? null) && empty($query['userId'] ?? null)) {
            return new JsonResponse(
                ['error' => 'Email ou identifiant obligatoire'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // Si les deux sont fournis, renvoyer une erreur
        if (!empty($query['email']) && !empty($query['userId'])) {
            return new JsonResponse(
                ['error' => 'Utilisez soit un email, soit un ID, pas les deux'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // Récupère le paramètre (email ou ID)
        $param = $query['email'] ?? $query['userId'];

        // Appelle le repository
        $profil = $user->getProfilUser($param);

        if (!$profil) {
            return new JsonResponse(
                ['error' => 'Aucun compte trouvé'],
                JsonResponse::HTTP_NOT_FOUND
            );
        }

        foreach ($profil as $value) {
            $communicationMethode[] = $value['communicationMethod'];

            $result = [
               'account_informations' => [
                   'businessName'               => $value['businessName'] ?? null,            
                   'businessRegistrationNumber' => $value['businessRegistrationNumber'] ?? null,            
                   'businessAddress'            => $value['businessAddress'] ?? null,            
                   'city'                       => $value['city'] ?? null,            
                   'postalCode'                 => $value['postalCode'] ?? null,            
                   'phoneNumber'                => $value['phoneNumber'] ?? null,            
                   'emailAddress'               => $value['emailAddress'] ?? null,            
                   'website'                    => $value['website'] ?? null            
               ],
               'financial_informations' => [
                   'vatNumber'                  => $value['vatNumber'] ?? null,            
                   'taxIdentificationNumber'    => $value['taxIdentificationNumber'] ?? null,            
                   'bankName'                   => $value['bankName'] ?? null,            
                   'bankAccountNumber'          => $value['bankAccountNumber'] ?? null,
                   'swiftCode'                  => $value['swiftCode'] ?? null
               ], 
               'adminstrative_settigs' => [
                    'primaryContactName'        => $value['primaryContactName'] ?? null,            
                    'primaryContactPost'        => $value['primaryContactPost'] ?? null,            
                    'notification'              => $value['notification'] ?? null,   
                    'communicationMethod'       => $communicationMethode       
               ]
           ];
        }

        return new JsonResponse($result);
    }
}