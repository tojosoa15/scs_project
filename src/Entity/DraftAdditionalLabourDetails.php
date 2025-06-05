<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftAdditionalLabourDetails
 *
 * @ORM\Table(name="draft_additional_labour_details", indexes={@ORM\Index(name="IDX_5475CC823DA4B3CF", columns={"vats_id"})})
 * @ORM\Entity
 */
class DraftAdditionalLabourDetails
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
     * @ORM\Column(name="eor_or_surveyor", type="string", length=10, nullable=true)
     */
    private $eorOrSurveyor;

    /**
     * @var string|null
     *
     * @ORM\Column(name="painting_cost", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $paintingCost;

    /**
     * @var string|null
     *
     * @ORM\Column(name="painting_materiels", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $paintingMateriels;

    /**
     * @var string|null
     *
     * @ORM\Column(name="sundries", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $sundries;

    /**
     * @var int|null
     *
     * @ORM\Column(name="num_of_repaire_days", type="integer", nullable=true)
     */
    private $numOfRepaireDays;

    /**
     * @var string|null
     *
     * @ORM\Column(name="discount_add_labour", type="decimal", precision=5, scale=2, nullable=true)
     */
    private $discountAddLabour;

    /**
     * @var string|null
     *
     * @ORM\Column(name="add_labour_total", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $addLabourTotal;

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

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getEorOrSurveyor(): ?string
    {
        return $this->eorOrSurveyor;
    }

    public function setEorOrSurveyor(?string $eorOrSurveyor): static
    {
        $this->eorOrSurveyor = $eorOrSurveyor;

        return $this;
    }

    public function getPaintingCost(): ?string
    {
        return $this->paintingCost;
    }

    public function setPaintingCost(?string $paintingCost): static
    {
        $this->paintingCost = $paintingCost;

        return $this;
    }

    public function getPaintingMateriels(): ?string
    {
        return $this->paintingMateriels;
    }

    public function setPaintingMateriels(?string $paintingMateriels): static
    {
        $this->paintingMateriels = $paintingMateriels;

        return $this;
    }

    public function getSundries(): ?string
    {
        return $this->sundries;
    }

    public function setSundries(?string $sundries): static
    {
        $this->sundries = $sundries;

        return $this;
    }

    public function getNumOfRepaireDays(): ?int
    {
        return $this->numOfRepaireDays;
    }

    public function setNumOfRepaireDays(?int $numOfRepaireDays): static
    {
        $this->numOfRepaireDays = $numOfRepaireDays;

        return $this;
    }

    public function getDiscountAddLabour(): ?string
    {
        return $this->discountAddLabour;
    }

    public function setDiscountAddLabour(?string $discountAddLabour): static
    {
        $this->discountAddLabour = $discountAddLabour;

        return $this;
    }

    public function getAddLabourTotal(): ?string
    {
        return $this->addLabourTotal;
    }

    public function setAddLabourTotal(?string $addLabourTotal): static
    {
        $this->addLabourTotal = $addLabourTotal;

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


}
