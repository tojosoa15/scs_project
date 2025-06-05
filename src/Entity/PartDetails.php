<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * PartDetails
 *
 * @ORM\Table(name="part_details", indexes={@ORM\Index(name="IDX_F27AFC813DA4B3CF", columns={"vats_id"}), @ORM\Index(name="IDX_F27AFC811000E6A", columns={"estimate_of_repairs_id"})})
 * @ORM\Entity
 */
class PartDetails
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
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $partName;

    /**
     * @var int
     *
     * @ORM\Column(name="quantity", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $quantity;

    /**
     * @var string
     *
     * @ORM\Column(name="supplier", type="string", length=255, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $supplier;

    /**
     * @var string
     *
     * @ORM\Column(name="quality", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $quality;

    /**
     * @var string
     *
     * @ORM\Column(name="cost_part", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $costPart;

    /**
     * @var string
     *
     * @ORM\Column(name="discount_part", type="decimal", precision=5, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $discountPart;

    /**
     * @var string|null
     *
     * @ORM\Column(name="part_total", type="decimal", precision=10, scale=2, nullable=true)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $partTotal;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $createdAt = null;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updatedAt = null;

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
     * @var \EstimateOfRepairs
     *
     * @ORM\ManyToOne(targetEntity="EstimateOfRepairs")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="estimate_of_repairs_id", referencedColumnName="id")
     * })
     */
    private $estimateOfRepairs;

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

    public function getEstimateOfRepairs(): ?EstimateOfRepairs
    {
        return $this->estimateOfRepairs;
    }

    public function setEstimateOfRepairs(?EstimateOfRepairs $estimateOfRepairs): static
    {
        $this->estimateOfRepairs = $estimateOfRepairs;

        return $this;
    }


}
