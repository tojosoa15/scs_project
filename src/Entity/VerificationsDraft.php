<?php

namespace App\Entity;

use App\Entity\Claims;
use App\Entity\Users;
use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\QueryParameter;
use App\Controller\VerificationSurveyorController;
use Doctrine\ORM\Mapping as ORM;

/**
 * VerificationsDraft
 *
 * @ORM\Table(name="verifications_draft", indexes={@ORM\Index(name="IDX_AFAC83B51EBA1364", columns={"surveyor_id"}), @ORM\Index(name="IDX_AFAC83B587B1A554", columns={"claims_id"})})
 * @ORM\Entity
 */
#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/surveyor_summary',
            controller: VerificationSurveyorController::class . '::getSummarySurveyor', 
            parameters: [ 'claim_number' => new QueryParameter(), 'surveyor_id' => new QueryParameter()]
        )
    ]
)]
class VerificationsDraft
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
     * @var string|null
     *
     * @ORM\Column(name="current_step", type="string", length=10, nullable=true)
     */
    private $currentStep;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $createdAt = 'CURRENT_TIMESTAMP';

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updatedAt = 'CURRENT_TIMESTAMP';

    /**
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="surveyor_id", referencedColumnName="id")
     * })
     */
    private ?Users $surveyor = null;

    /**
     * @var \Claims
     *
     * @ORM\ManyToOne(targetEntity="Claims")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="claims_id", referencedColumnName="id")
     * })
     */
    // Le nom du champs est claims_id et il fait reference à l'id de l'entity claims
    private ?Claims $claims=null;


    /**
     * @var DraftSurveyInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\DraftSurveyInformations", mappedBy="verificationsDraft", cascade={"persist", "remove"})
     */
    private ?DraftSurveyInformations $draftSurveyInformations = null;


    /**
     * @var DraftEstimateOfRepairs|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\DraftEstimateOfRepairs", mappedBy="verificationsDraft", cascade={"persist", "remove"})
     */
    private ?DraftEstimateOfRepairs $draftEstimateOfRepairs = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCurrentStep(): ?string
    {
        return $this->currentStep;
    }

    public function setCurrentStep(?string $currentStep): static
    {
        $this->currentStep = $currentStep;

        return $this;
    }

    public function getCreatedAt(): ?\DateTime
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTime $createdAt): static
    {
        $this->createdAt = $createdAt;

        return $this;
    }

    public function getUpdatedAt(): ?\DateTime
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTime $updatedAt): static
    {
        $this->updatedAt = $updatedAt;

        return $this;
    }

    public function getSurveyor(): ?Users
    {
        return $this->surveyor;
    }

    public function setSurveyor(?Users $surveyor): static
    {
        $this->surveyor = $surveyor;

        return $this;
    }

    public function getClaims(): ?Claims
    {
        return $this->claims;
    }

    public function setClaims(?Claims $claims): static
    {
        $this->claims = $claims;

        return $this;
    }

    public function getDraftSurveyInformations(): ?DraftSurveyInformations
    {
        return $this->draftSurveyInformations;
    }

    public function setDraftSurveyInformations(?DraftSurveyInformations $draftSurveyInformations): static
    {
        $this->draftSurveyInformations = $draftSurveyInformations;

        return $this;
    }

    public function getDraftEstimateOfRepairs(): ?DraftEstimateOfRepairs
    {
        return $this->draftEstimateOfRepairs;
    }

    public function setDraftEstimateOfRepairs(?DraftEstimateOfRepairs $draftEstimateOfRepairs): static
    {
        $this->draftEstimateOfRepairs = $draftEstimateOfRepairs;

        return $this;
    }
}
