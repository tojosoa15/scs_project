<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\QueryParameter;
use App\Controller\GetClaimsByUserController;
use App\Controller\GetClaimDetailsController;
use App\Controller\GetUserProfileController;
use Doctrine\ORM\Mapping as ORM;

/**
 * Survey
 *
 * @ORM\Table(name="survey", indexes={@ORM\Index(name="fk_survey_status1_idx", columns={"status_id"})})
 * @ORM\Entity
 */
#[ApiResource(
    operations: [
        // Liste claim d'un utilisateur
        new GetCollection(
            uriTemplate: '/list/claims_user',
            controller: GetClaimsByUserController::class,
            parameters: [ 'email' => new QueryParameter()],
        ),
        // Détail d'un claim 
        new Get(
            uriTemplate: '/claim/details_with_survey',
            controller: GetClaimDetailsController::class,
            parameters: [ 'p_claim_number' => new QueryParameter()]
        ),
        // Profile utilisateur
        new Get(
            uriTemplate: '/profile_user',
            controller: GetUserProfileController::class,
            parameters: [ 'p_email_address' => new QueryParameter()]
        )
    ]
)]

class Survey
{
    /**
     * @var int
     *
     * @ORM\Column(name="id", type="integer", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="IDENTITY")
     */
    private $id;

    /**
     * @var int
     *
     * @ORM\Column(name="claim_id", type="integer", nullable=false)
     */
    private $claimId;

    /**
     * @var int
     *
     * @ORM\Column(name="surveyor_id", type="integer", nullable=false)
     */
    private $surveyorId;

    /**
     * @var string|null
     *
     * @ORM\Column(name="current_step", type="string", length=45, nullable=true)
     */
    private $currentStep;

    /**
     * @var \Status
     *
     * @ORM\ManyToOne(targetEntity="Status")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="status_id", referencedColumnName="id")
     * })
     */
    private $status;


}
