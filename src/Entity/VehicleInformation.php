<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * VehicleInformation
 *
 * @ORM\Table(name="vehicle_information", indexes={@ORM\Index(name="fk_vehicle_information_verification1_idx", columns={"verification_id"})})
 * @ORM\Entity
 */
class VehicleInformation
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
     * @ORM\Column(name="make", type="string", length=90, nullable=true)
     */
    private $make;

    /**
     * @var string|null
     *
     * @ORM\Column(name="model", type="string", length=90, nullable=true)
     */
    private $model;

    /**
     * @var int|null
     *
     * @ORM\Column(name="cc", type="integer", nullable=true)
     */
    private $cc;

    /**
     * @var string|null
     *
     * @ORM\Column(name="fuel_type", type="string", length=45, nullable=true)
     */
    private $fuelType;

    /**
     * @var string|null
     *
     * @ORM\Column(name="transmission", type="string", length=45, nullable=true)
     */
    private $transmission;

    /**
     * @var string|null
     *
     * @ORM\Column(name="engime_no", type="string", length=90, nullable=true)
     */
    private $engimeNo;

    /**
     * @var int|null
     *
     * @ORM\Column(name="chasisi_no", type="integer", nullable=true)
     */
    private $chasisiNo;

    /**
     * @var string|null
     *
     * @ORM\Column(name="vehicle_no", type="string", length=45, nullable=true)
     */
    private $vehicleNo;

    /**
     * @var string|null
     *
     * @ORM\Column(name="color", type="string", length=45, nullable=true)
     */
    private $color;

    /**
     * @var int|null
     *
     * @ORM\Column(name="odometer_reading", type="integer", nullable=true)
     */
    private $odometerReading;

    /**
     * @var bool|null
     *
     * @ORM\Column(name="is_the_vehicle_total_loss", type="boolean", nullable=true)
     */
    private $isTheVehicleTotalLoss;

    /**
     * @var string|null
     *
     * @ORM\Column(name="condition_of_vehicle", type="string", length=10, nullable=true)
     */
    private $conditionOfVehicle;

    /**
     * @var string|null
     *
     * @ORM\Column(name="place_of_survey", type="string", length=150, nullable=true)
     */
    private $placeOfSurvey;

    /**
     * @var string|null
     *
     * @ORM\Column(name="point_of_impact", type="text", length=16, nullable=true)
     */
    private $pointOfImpact;

    /**
     * @var \Survey
     *
     * @ORM\ManyToOne(targetEntity="Survey")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verification_id", referencedColumnName="id")
     * })
     */
    private $verification;


}
