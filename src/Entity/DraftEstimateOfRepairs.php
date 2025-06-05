<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftEstimateOfRepairs
 *
 * @ORM\Table(name="draft_estimate_of_repairs", indexes={@ORM\Index(name="IDX_1AA2DC8F87B1A554", columns={"claims_id"}), @ORM\Index(name="IDX_1AA2DC8F6A1ADD2F", columns={"verifications_draft_id"}), @ORM\Index(name="IDX_1AA2DC8FC3D0177B", columns={"draft_additional_labour_details_id"})})
 * @ORM\Entity
 */
class DraftEstimateOfRepairs
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
     * @ORM\Column(name="current_editor", type="string", length=10, nullable=true)
     */
    private $currentEditor;

    /**
     * @var string|null
     *
     * @ORM\Column(name="remarks", type="text", length=16, nullable=true)
     */
    private $remarks;

    /**
     * @var \Claims
     *
     * @ORM\ManyToOne(targetEntity="Claims")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="claims_id", referencedColumnName="id")
     * })
     */
    private $claims;

    /**
     * @var \VerificationsDraft
     *
     * @ORM\ManyToOne(targetEntity="VerificationsDraft")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verifications_draft_id", referencedColumnName="id")
     * })
     */
    private ?VerificationsDraft $verificationsDraft = null; 

    /**
     * @var \DraftAdditionalLabourDetails
     *
     * @ORM\ManyToOne(targetEntity="DraftAdditionalLabourDetails")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_additional_labour_details_id", referencedColumnName="id")
     * })
     */
    private ?DraftAdditionalLabourDetails $draftAdditionalLabourDetails = null;

    /**
     * @var DraftVehicleInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\DraftVehicleInformations", mappedBy="draftEstimateOfRepairs", cascade={"persist", "remove"})
     */
    private ?DraftVehicleInformations $draftVehicleInformations = null;

    /**
     * @var DraftPartDetails|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\DraftPartDetails", mappedBy="draftEstimateOfRepairs", cascade={"persist", "remove"})
     */
    private ?DraftPartDetails $draftPartDetails = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCurrentEditor(): ?string
    {
        return $this->currentEditor;
    }

    public function setCurrentEditor(?string $currentEditor): static
    {
        $this->currentEditor = $currentEditor;

        return $this;
    }

    public function getRemarks(): ?string
    {
        return $this->remarks;
    }

    public function setRemarks(?string $remarks): static
    {
        $this->remarks = $remarks;

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

    public function getVerificationsDraft(): ?VerificationsDraft
    {
        return $this->verificationsDraft;
    }

    public function setVerificationsDraft(?VerificationsDraft $verificationsDraft): static
    {
        $this->verificationsDraft = $verificationsDraft;

        return $this;
    }

    public function getDraftAdditionalLabourDetails(): ?DraftAdditionalLabourDetails
    {
        return $this->draftAdditionalLabourDetails;
    }

    public function setDraftAdditionalLabourDetails(?DraftAdditionalLabourDetails $draftAdditionalLabourDetails): static
    {
        $this->draftAdditionalLabourDetails = $draftAdditionalLabourDetails;

        return $this;
    }

    public function getDraftEstimateOfRepairs(): ?DraftVehicleInformations
    {
        return $this->draftVehicleInformations;
    }

    public function setDraftEstimateOfRepairs(?DraftVehicleInformations $draftVehicleInformations): static
    {
        $this->draftVehicleInformations = $draftVehicleInformations;

        return $this;
    }
    
    public function getDraftPartDetails(): ?DraftPartDetails
    {
        return $this->draftPartDetails;
    }

    public function setDraftPartDetails(?DraftPartDetails $draftPartDetails): static
    {
        $this->draftPartDetails = $draftPartDetails;

        return $this;
    }

}
