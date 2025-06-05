<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * SurveyorAssignment
 *
 * @ORM\Table(name="surveyor_assignment", indexes={@ORM\Index(name="IDX_FC063D551EBA1364", columns={"surveyor_id"}), @ORM\Index(name="IDX_FC063D556BF700BD", columns={"status_id"})})
 * @ORM\Entity
 */
class SurveyorAssignment
{
    /**
     * @var int|null
     *
     * @ORM\Column(name="garage_id", type="integer", nullable=true)
     */
    private $garageId;

    /**
     * @var int|null
     *
     * @ORM\Column(name="spare_parts_id", type="integer", nullable=true)
     */
    private $sparePartsId;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="assignment_date", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $assignmentDate = 'CURRENT_TIMESTAMP';

    /**
     * @var string|null
     *
     * @ORM\Column(name="assignment_notes", type="string", length=250, nullable=true)
     */
    private $assignmentNotes;

    /**
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="surveyor_id", referencedColumnName="id")
     * })
     */
    private $surveyor;

    /**
     * @var \Claims
     *
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="NONE")
     * @ORM\OneToOne(targetEntity="Claims")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="claims_id", referencedColumnName="id")
     * })
     */
    private $claims;

    /**
     * @var \Status
     *
     * @ORM\ManyToOne(targetEntity="Status")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="status_id", referencedColumnName="id")
     * })
     */
    private $status;

    public function getGarageId(): ?int
    {
        return $this->garageId;
    }

    public function setGarageId(?int $garageId): static
    {
        $this->garageId = $garageId;

        return $this;
    }

    public function getSparePartsId(): ?int
    {
        return $this->sparePartsId;
    }

    public function setSparePartsId(?int $sparePartsId): static
    {
        $this->sparePartsId = $sparePartsId;

        return $this;
    }

    public function getAssignmentDate(): ?\DateTime
    {
        return $this->assignmentDate;
    }

    public function setAssignmentDate(?\DateTime $assignmentDate): static
    {
        $this->assignmentDate = $assignmentDate;

        return $this;
    }

    public function getAssignmentNotes(): ?string
    {
        return $this->assignmentNotes;
    }

    public function setAssignmentNotes(?string $assignmentNotes): static
    {
        $this->assignmentNotes = $assignmentNotes;

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

    public function getStatus(): ?Status
    {
        return $this->status;
    }

    public function setStatus(?Status $status): static
    {
        $this->status = $status;

        return $this;
    }


}
