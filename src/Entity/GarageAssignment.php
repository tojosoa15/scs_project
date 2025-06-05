<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * GarageAssignment
 *
 * @ORM\Table(name="garage_Assignment", indexes={@ORM\Index(name="IDX_69C026CC4FFF555", columns={"garage_id"})})
 * @ORM\Entity
 */
class GarageAssignment
{
    /**
     * @var int|null
     *
     * @ORM\Column(name="surveyor_id", type="integer", nullable=true)
     */
    private $surveyorId;

    /**
     * @var int|null
     *
     * @ORM\Column(name="spare-parts_id", type="integer", nullable=true)
     */
    private $sparePartsId;

    /**
     * @var string|null
     *
     * @ORM\Column(name="status", type="string", length=45, nullable=true)
     */
    private $status;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="date", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $date = 'CURRENT_TIMESTAMP';

    /**
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="garage_id", referencedColumnName="id")
     * })
     */
    private $garage;

    /**
     * @var \Claims
     *
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="NONE")
     * @ORM\OneToOne(targetEntity="Claims")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="claim_id", referencedColumnName="id")
     * })
     */
    private $claim;

    public function getSurveyorId(): ?int
    {
        return $this->surveyorId;
    }

    public function setSurveyorId(?int $surveyorId): static
    {
        $this->surveyorId = $surveyorId;

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

    public function getStatus(): ?string
    {
        return $this->status;
    }

    public function setStatus(?string $status): static
    {
        $this->status = $status;

        return $this;
    }

    public function getDate(): ?\DateTime
    {
        return $this->date;
    }

    public function setDate(?\DateTime $date): static
    {
        $this->date = $date;

        return $this;
    }

    public function getGarage(): ?Users
    {
        return $this->garage;
    }

    public function setGarage(?Users $garage): static
    {
        $this->garage = $garage;

        return $this;
    }

    public function getClaim(): ?Claims
    {
        return $this->claim;
    }

    public function setClaim(?Claims $claim): static
    {
        $this->claim = $claim;

        return $this;
    }


}
