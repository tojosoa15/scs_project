<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftPartDetails
 *
 * @ORM\Table(name="draft_part_details", indexes={@ORM\Index(name="IDX_988BE75C3DA4B3CF", columns={"vats_id"}), @ORM\Index(name="IDX_988BE75C997DD140", columns={"draft_estimate_of_repairs_id"})})
 * @ORM\Entity
 */
class DraftPartDetails
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
     * @var string
     *
     * @ORM\Column(name="part_name", type="string", length=150, nullable=false)
     */
    private $partName;

    /**
     * @var int
     *
     * @ORM\Column(name="quantity", type="integer", nullable=false)
     */
    private $quantity;

    /**
     * @var string
     *
     * @ORM\Column(name="supplier", type="string", length=255, nullable=false)
     */
    private $supplier;

    /**
     * @var string
     *
     * @ORM\Column(name="quality", type="string", length=45, nullable=false)
     */
    private $quality;

    /**
     * @var string
     *
     * @ORM\Column(name="cost_part", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $costPart;

    /**
     * @var string
     *
     * @ORM\Column(name="discount_part", type="decimal", precision=5, scale=2, nullable=false)
     */
    private $discountPart;

    /**
     * @var string|null
     *
     * @ORM\Column(name="part_total", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $partTotal;

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
     * @var \Vats
     *
     * @ORM\ManyToOne(targetEntity="Vats")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="vats_id", referencedColumnName="id")
     * })
     */
    private $vats;

    /**
     * @var \DraftEstimateOfRepairs
     *
     * @ORM\ManyToOne(targetEntity="DraftEstimateOfRepairs")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_estimate_of_repairs_id", referencedColumnName="id")
     * })
     */
    private $draftEstimateOfRepairs;

    /**
     * @var DraftLabourDetails|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\DraftLabourDetails", mappedBy="draftPartDetails", cascade={"persist", "remove"})
     */
    private ?DraftLabourDetails $draftLabourDetails = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPartName(): ?string
    {
        return $this->partName;
    }

    public function setPartName(string $partName): static
    {
        $this->partName = $partName;

        return $this;
    }

    public function getQuantity(): ?int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): static
    {
        $this->quantity = $quantity;

        return $this;
    }

    public function getSupplier(): ?string
    {
        return $this->supplier;
    }

    public function setSupplier(string $supplier): static
    {
        $this->supplier = $supplier;

        return $this;
    }

    public function getQuality(): ?string
    {
        return $this->quality;
    }

    public function setQuality(string $quality): static
    {
        $this->quality = $quality;

        return $this;
    }

    public function getCostPart(): ?string
    {
        return $this->costPart;
    }

    public function setCostPart(string $costPart): static
    {
        $this->costPart = $costPart;

        return $this;
    }

    public function getDiscountPart(): ?string
    {
        return $this->discountPart;
    }

    public function setDiscountPart(string $discountPart): static
    {
        $this->discountPart = $discountPart;

        return $this;
    }

    public function getPartTotal(): ?string
    {
        return $this->partTotal;
    }

    public function setPartTotal(?string $partTotal): static
    {
        $this->partTotal = $partTotal;

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

    public function getVats(): ?Vats
    {
        return $this->vats;
    }

    public function setVats(?Vats $vats): static
    {
        $this->vats = $vats;

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
