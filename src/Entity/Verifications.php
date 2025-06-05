<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\Controller\VerificationSurveyorController;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * Verifications
 *
 * @ORM\Table(name="verifications", indexes={@ORM\Index(name="IX_verifications_claims_id", columns={"claims_id"}), @ORM\Index(name="IX_verifications_user_id", columns={"user_id"})})
 * @ORM\Entity
 */
#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/verifications_process/by_surveyor',
            controller: VerificationSurveyorController::class . '::verificationProcessSurveyor',
        )
    ]
)]
class Verifications
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
     * @ORM\Column(name="claims_id", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $claimsId;

    /**
     * @var int
     *
     * @ORM\Column(name="user_id", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $userId;

    /**
     * @var bool|null
     *
     * @ORM\Column(name="is_submitted", type="boolean", nullable=true)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $isSubmitted;

    /**
     * @var string|null
     *
     * @ORM\Column(name="current_step", type="string", length=45, nullable=true)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $currentStep;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true)
     */
    private $createdAt;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true)
     */
    private $updatedAt;


    /**
     * @var SurveyInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\SurveyInformations", mappedBy="verifications", cascade={"persist", "remove"})
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private ?SurveyInformations $surveyInformations = null;

    /**
     * @var EstimateOfRepairs|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\EstimateOfRepairs", mappedBy="verifications", cascade={"persist", "remove"})
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private ?EstimateOfRepairs $estimateOfRepairs = null;

    /**
     * @ORM\PrePersist
     */
    public function setTimestampsOnCreate(): void
    {
        $this->createdAt = new \DateTime();
        $this->updatedAt = new \DateTime();
    }

    /**
     * @ORM\PreUpdate
     */
    public function setTimestampOnUpdate(): void
    {
        $this->updatedAt = new \DateTime();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getClaimsId(): ?int
    {
        return $this->claimsId;
    }

    public function setClaimsId(int $claimsId): static
    {
        $this->claimsId = $claimsId;

        return $this;
    }

    public function getUserId(): ?int
    {
        return $this->userId;
    }

    public function setUserId(int $userId): static
    {
        $this->userId = $userId;

        return $this;
    }

    public function isSubmitted(): ?bool
    {
        return $this->isSubmitted;
    }

    public function setIsSubmitted(?bool $isSubmitted): static
    {
        $this->isSubmitted = $isSubmitted;

        return $this;
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

    public function getEstimateOfRepairs(): ?EstimateOfRepairs
    {
        return $this->estimateOfRepairs;
    }

    public function setEstimateOfRepairs(?EstimateOfRepairs $estimateOfRepairs): self
    {
        // Nettoyage de l'ancienne relation
        if ($this->estimateOfRepairs !== null && $this->estimateOfRepairs->getVerifications() === $this) {
            $this->estimateOfRepairs->setVerifications(null);
        }

        // Mise à jour de la nouvelle relation
        $this->estimateOfRepairs = $estimateOfRepairs;

        // Définition de la relation inverse
        if ($estimateOfRepairs !== null && $estimateOfRepairs->getVerifications() !== $this) {
            $estimateOfRepairs->setVerifications($this);
        }

        return $this;
    }

}
