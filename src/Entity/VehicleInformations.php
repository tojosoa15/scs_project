<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * VehicleInformations
 *
 * @ORM\Table(name="vehicle_informations", indexes={@ORM\Index(name="IDX_D67E8BFDA1570E7E", columns={"condition_of_vechicle_id"}), @ORM\Index(name="IDX_D67E8BFD1000E6A", columns={"estimate_of_repairs_id"})})
 * @ORM\Entity
 */
class VehicleInformations
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
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $make;

    /**
     * @var string
     *
     * @ORM\Column(name="model", type="string", length=100, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $model;

    /**
     * @var int
     *
     * @ORM\Column(name="cc", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $cc;

    /**
     * @var string
     *
     * @ORM\Column(name="fuel_type", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $fuelType;

    /**
     * @var string
     *
     * @ORM\Column(name="transmission", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $transmission;

    /**
     * @var string
     *
     * @ORM\Column(name="engime_number", type="string", length=100, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $engimeNumber;

    /**
     * @var int
     *
     * @ORM\Column(name="chasisi_number", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $chasisiNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="vehicle_number", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $vehicleNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="color", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $color;

    /**
     * @var int
     *
     * @ORM\Column(name="odometer_reading", type="integer", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $odometerReading;

    /**
     * @var bool
     *
     * @ORM\Column(name="is_the_vehicle_total_loss", type="boolean", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $isTheVehicleTotalLoss = '0';

    /**
     * @var string
     *
     * @ORM\Column(name="place_of_survey", type="string", length=150, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $placeOfSurvey;

    /**
     * @var string
     *
     * @ORM\Column(name="point_of_impact", type="text", length=16, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $pointOfImpact;

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
     * @var \ConditionOfVechicle
     *
     * @ORM\ManyToOne(targetEntity="ConditionOfVechicle")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="condition_of_vechicle_id", referencedColumnName="id")
     * })
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $conditionOfVechicle;

    /**
     * @var \EstimateOfRepairs
     *
     * @ORM\ManyToOne(targetEntity="EstimateOfRepairs")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="estimate_of_repairs_id", referencedColumnName="id")
     * })
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $estimateOfRepairs;

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

    public function getConditionOfVechicle(): ?ConditionOfVechicle
    {
        return $this->conditionOfVechicle;
    }

    public function setConditionOfVechicle(?ConditionOfVechicle $conditionOfVechicle): static
    {
        $this->conditionOfVechicle = $conditionOfVechicle;

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
