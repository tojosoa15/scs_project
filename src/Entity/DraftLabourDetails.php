<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftLabourDetails
 *
 * @ORM\Table(name="draft_labour_details", indexes={@ORM\Index(name="IDX_B0397C2F3DA4B3CF", columns={"vats_id"}), @ORM\Index(name="IDX_B0397C2F68B22DFF", columns={"draft_part_details_id"})})
 * @ORM\Entity
 */
class DraftLabourDetails
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
     * @var string
     *
     * @ORM\Column(name="activity", type="string", length=45, nullable=false)
     */
    private $activity;

    /**
     * @var int
     *
     * @ORM\Column(name="number_of_hours", type="integer", nullable=false)
     */
    private $numberOfHours;

    /**
     * @var string
     *
     * @ORM\Column(name="hourly_cost_labour", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $hourlyCostLabour;

    /**
     * @var string
     *
     * @ORM\Column(name="discount_labour", type="decimal", precision=5, scale=2, nullable=false)
     */
    private $discountLabour;

    /**
     * @var string|null
     *
     * @ORM\Column(name="labour_total", type="decimal", precision=10, scale=2, nullable=true)
     */
    private $labourTotal;

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
     * @var \DraftPartDetails
     *
     * @ORM\ManyToOne(targetEntity="DraftPartDetails")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_part_details_id", referencedColumnName="id")
     * })
     */
    private $draftPartDetails;

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

    public function getActivity(): ?string
    {
        return $this->activity;
    }

    public function setActivity(string $activity): static
    {
        $this->activity = $activity;

        return $this;
    }

    public function getNumberOfHours(): ?int
    {
        return $this->numberOfHours;
    }

    public function setNumberOfHours(int $numberOfHours): static
    {
        $this->numberOfHours = $numberOfHours;

        return $this;
    }

    public function getHourlyCostLabour(): ?string
    {
        return $this->hourlyCostLabour;
    }

    public function setHourlyCostLabour(string $hourlyCostLabour): static
    {
        $this->hourlyCostLabour = $hourlyCostLabour;

        return $this;
    }

    public function getDiscountLabour(): ?string
    {
        return $this->discountLabour;
    }

    public function setDiscountLabour(string $discountLabour): static
    {
        $this->discountLabour = $discountLabour;

        return $this;
    }

    public function getLabourTotal(): ?string
    {
        return $this->labourTotal;
    }

    public function setLabourTotal(?string $labourTotal): static
    {
        $this->labourTotal = $labourTotal;

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
