<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftVehicleInformations
 *
 * @ORM\Table(name="draft_vehicle_informations", indexes={@ORM\Index(name="IDX_23F38554997DD140", columns={"draft_estimate_of_repairs_id"})})
 * @ORM\Entity
 */
class DraftVehicleInformations
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
     * @ORM\Column(name="make", type="string", length=100, nullable=false)
     */
    private $make;

    /**
     * @var string
     *
     * @ORM\Column(name="model", type="string", length=100, nullable=false)
     */
    private $model;

    /**
     * @var int
     *
     * @ORM\Column(name="cc", type="integer", nullable=false)
     */
    private $cc;

    /**
     * @var string
     *
     * @ORM\Column(name="fuel_type", type="string", length=45, nullable=false)
     */
    private $fuelType;

    /**
     * @var string
     *
     * @ORM\Column(name="transmission", type="string", length=45, nullable=false)
     */
    private $transmission;

    /**
     * @var string
     *
     * @ORM\Column(name="engime_number", type="string", length=100, nullable=false)
     */
    private $engimeNumber;

    /**
     * @var int
     *
     * @ORM\Column(name="chasisi_number", type="integer", nullable=false)
     */
    private $chasisiNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="vehicle_number", type="string", length=45, nullable=false)
     */
    private $vehicleNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="color", type="string", length=45, nullable=false)
     */
    private $color;

    /**
     * @var int
     *
     * @ORM\Column(name="odometer_reading", type="integer", nullable=false)
     */
    private $odometerReading;

    /**
     * @var bool
     *
     * @ORM\Column(name="is_the_vehicle_total_loss", type="boolean", nullable=false)
     */
    private $isTheVehicleTotalLoss = '0';

    /**
     * @var string
     *
     * @ORM\Column(name="place_of_survey", type="string", length=150, nullable=false)
     */
    private $placeOfSurvey;

    /**
     * @var string
     *
     * @ORM\Column(name="point_of_impact", type="text", length=16, nullable=false)
     */
    private $pointOfImpact;

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
     * @var \DraftEstimateOfRepairs
     *
     * @ORM\ManyToOne(targetEntity="DraftEstimateOfRepairs")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_estimate_of_repairs_id", referencedColumnName="id")
     * })
     */
    private ?DraftEstimateOfRepairs $draftEstimateOfRepairs = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getMake(): ?string
    {
        return $this->make;
    }

    public function setMake(string $make): static
    {
        $this->make = $make;

        return $this;
    }

    public function getModel(): ?string
    {
        return $this->model;
    }

    public function setModel(string $model): static
    {
        $this->model = $model;

        return $this;
    }

    public function getCc(): ?int
    {
        return $this->cc;
    }

    public function setCc(int $cc): static
    {
        $this->cc = $cc;

        return $this;
    }

    public function getFuelType(): ?string
    {
        return $this->fuelType;
    }

    public function setFuelType(string $fuelType): static
    {
        $this->fuelType = $fuelType;

        return $this;
    }

    public function getTransmission(): ?string
    {
        return $this->transmission;
    }

    public function setTransmission(string $transmission): static
    {
        $this->transmission = $transmission;

        return $this;
    }

    public function getEngimeNumber(): ?string
    {
        return $this->engimeNumber;
    }

    public function setEngimeNumber(string $engimeNumber): static
    {
        $this->engimeNumber = $engimeNumber;

        return $this;
    }

    public function getChasisiNumber(): ?int
    {
        return $this->chasisiNumber;
    }

    public function setChasisiNumber(int $chasisiNumber): static
    {
        $this->chasisiNumber = $chasisiNumber;

        return $this;
    }

    public function getVehicleNumber(): ?string
    {
        return $this->vehicleNumber;
    }

    public function setVehicleNumber(string $vehicleNumber): static
    {
        $this->vehicleNumber = $vehicleNumber;

        return $this;
    }

    public function getColor(): ?string
    {
        return $this->color;
    }

    public function setColor(string $color): static
    {
        $this->color = $color;

        return $this;
    }

    public function getOdometerReading(): ?int
    {
        return $this->odometerReading;
    }

    public function setOdometerReading(int $odometerReading): static
    {
        $this->odometerReading = $odometerReading;

        return $this;
    }

    public function isTheVehicleTotalLoss(): ?bool
    {
        return $this->isTheVehicleTotalLoss;
    }

    public function setIsTheVehicleTotalLoss(bool $isTheVehicleTotalLoss): static
    {
        $this->isTheVehicleTotalLoss = $isTheVehicleTotalLoss;

        return $this;
    }

    public function getPlaceOfSurvey(): ?string
    {
        return $this->placeOfSurvey;
    }

    public function setPlaceOfSurvey(string $placeOfSurvey): static
    {
        $this->placeOfSurvey = $placeOfSurvey;

        return $this;
    }

    public function getPointOfImpact(): ?string
    {
        return $this->pointOfImpact;
    }

    public function setPointOfImpact(string $pointOfImpact): static
    {
        $this->pointOfImpact = $pointOfImpact;

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
