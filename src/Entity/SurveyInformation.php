<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * SurveyInformation
 *
 * @ORM\Table(name="survey_information", indexes={@ORM\Index(name="fk_survey_information_verification1_idx", columns={"verification_id"})})
 * @ORM\Entity
 */
class SurveyInformation
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
     * @ORM\Column(name="garage", type="string", length=45, nullable=false)
     */
    private $garage;

    /**
     * @var string
     *
     * @ORM\Column(name="garage_address", type="string", length=255, nullable=false)
     */
    private $garageAddress;

    /**
     * @var string
     *
     * @ORM\Column(name="garage_contact_number", type="string", length=100, nullable=false)
     */
    private $garageContactNumber;

    /**
     * @var float
     *
     * @ORM\Column(name="eor_value", type="float", precision=53, scale=0, nullable=false)
     */
    private $eorValue;

    /**
     * @var string
     *
     * @ORM\Column(name="invoice_number", type="string", length=45, nullable=false)
     */
    private $invoiceNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="survey_type", type="string", length=45, nullable=false)
     */
    private $surveyType;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="date_of_survey", type="date", nullable=false)
     */
    private $dateOfSurvey;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="time_of_survey", type="time", nullable=false)
     */
    private $timeOfSurvey;

    /**
     * @var float
     *
     * @ORM\Column(name="pre_accident_valeur", type="float", precision=53, scale=0, nullable=false)
     */
    private $preAccidentValeur;

    /**
     * @var float
     *
     * @ORM\Column(name="showroom_price", type="float", precision=53, scale=0, nullable=false)
     */
    private $showroomPrice;

    /**
     * @var float
     *
     * @ORM\Column(name="wrech_value", type="float", precision=53, scale=0, nullable=false)
     */
    private $wrechValue;

    /**
     * @var float
     *
     * @ORM\Column(name="excess_applicable", type="float", precision=53, scale=0, nullable=false)
     */
    private $excessApplicable;

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
