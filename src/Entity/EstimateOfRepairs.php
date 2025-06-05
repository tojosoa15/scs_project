<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * EstimateOfRepairs
 *
 * @ORM\Table(name="estimate_of_repairs", indexes={@ORM\Index(name="IDX_986822D841748AA", columns={"additional_labour_details_id"}), @ORM\Index(name="IDX_986822D887B1A554", columns={"claims_id"}), @ORM\Index(name="IDX_986822D87B277F0", columns={"verifications_id"})})
 * @ORM\Entity
 */
class EstimateOfRepairs
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
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $remarks;

    /**
     * @var \AdditionalLabourDetails
     *
     * @ORM\ManyToOne(targetEntity="AdditionalLabourDetails")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="additional_labour_details_id", referencedColumnName="id")
     * })
     */
    private $additionalLabourDetails;

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
     * @var \Verifications
     *
     * @ORM\ManyToOne(targetEntity="Verifications")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verifications_id", referencedColumnName="id")
     * })
     */
    private ?Verifications $verifications;


    /**
     * @var VehicleInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\VehicleInformations", mappedBy="estimateOfRepairs", cascade={"persist", "remove"})
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private ?VehicleInformations $vehicleInformations = null;

    /**
     * @var PartDetails
     *
     * @ORM\OneToMany(targetEntity="App\Entity\PartDetails", mappedBy="estimateOfRepairs", cascade={"persist", "remove"})
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $partDetails;

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

    public function getAdditionalLabourDetails(): ?AdditionalLabourDetails
    {
        return $this->additionalLabourDetails;
    }

    public function setAdditionalLabourDetails(?AdditionalLabourDetails $additionalLabourDetails): static
    {
        $this->additionalLabourDetails = $additionalLabourDetails;

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

    public function getVerifications(): ?Verifications
    {
        return $this->verifications;
    }

    public function setVerifications(?Verifications $verifications): static
    {
        $this->verifications = $verifications;

        return $this;
    }


}
