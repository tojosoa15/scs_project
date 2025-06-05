<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * DraftSurveyInformations
 *
 * @ORM\Table(name="draft_survey_informations", indexes={@ORM\Index(name="IDX_9D8E968E6A1ADD2F", columns={"verifications_draft_id"})})
 * @ORM\Entity
 */
class DraftSurveyInformations
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
     * @ORM\Column(name="garage_contact_number", type="string", length=45, nullable=false)
     */
    private $garageContactNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="eor_value", type="decimal", precision=10, scale=2, nullable=false)
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
     * @var string
     *
     * @ORM\Column(name="pre_accident_value", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $preAccidentValue;

    /**
     * @var string
     *
     * @ORM\Column(name="showroom_price", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $showroomPrice;

    /**
     * @var string
     *
     * @ORM\Column(name="wreck_value", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $wreckValue;

    /**
     * @var string
     *
     * @ORM\Column(name="excess_applicable", type="decimal", precision=10, scale=2, nullable=false)
     */
    private $excessApplicable;

    /**
     * @var string|null
     *
     * @ORM\Column(name="created_at", type="string", length=45, nullable=true)
     */
    private $createdAt;

    /**
     * @var string|null
     *
     * @ORM\Column(name="updated_at", type="string", length=45, nullable=true)
     */
    private $updatedAt;

    /**
     * @var \VerificationsDraft
     *
     * @ORM\ManyToOne(targetEntity="VerificationsDraft")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verifications_draft_id", referencedColumnName="id")
     * })
     */
    private ?VerificationsDraft $verificationsDraft;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getGarage(): ?string
    {
        return $this->garage;
    }

    public function setGarage(string $garage): static
    {
        $this->garage = $garage;

        return $this;
    }

    public function getGarageAddress(): ?string
    {
        return $this->garageAddress;
    }

    public function setGarageAddress(string $garageAddress): static
    {
        $this->garageAddress = $garageAddress;

        return $this;
    }

    public function getGarageContactNumber(): ?string
    {
        return $this->garageContactNumber;
    }

    public function setGarageContactNumber(string $garageContactNumber): static
    {
        $this->garageContactNumber = $garageContactNumber;

        return $this;
    }

    public function getEorValue(): ?string
    {
        return $this->eorValue;
    }

    public function setEorValue(string $eorValue): static
    {
        $this->eorValue = $eorValue;

        return $this;
    }

    public function getInvoiceNumber(): ?string
    {
        return $this->invoiceNumber;
    }

    public function setInvoiceNumber(string $invoiceNumber): static
    {
        $this->invoiceNumber = $invoiceNumber;

        return $this;
    }

    public function getSurveyType(): ?string
    {
        return $this->surveyType;
    }

    public function setSurveyType(string $surveyType): static
    {
        $this->surveyType = $surveyType;

        return $this;
    }

    public function getDateOfSurvey(): ?\DateTime
    {
        return $this->dateOfSurvey;
    }

    public function setDateOfSurvey(\DateTime $dateOfSurvey): static
    {
        $this->dateOfSurvey = $dateOfSurvey;

        return $this;
    }

    public function getTimeOfSurvey(): ?\DateTime
    {
        return $this->timeOfSurvey;
    }

    public function setTimeOfSurvey(\DateTime $timeOfSurvey): static
    {
        $this->timeOfSurvey = $timeOfSurvey;

        return $this;
    }

    public function getPreAccidentValue(): ?string
    {
        return $this->preAccidentValue;
    }

    public function setPreAccidentValue(string $preAccidentValue): static
    {
        $this->preAccidentValue = $preAccidentValue;

        return $this;
    }

    public function getShowroomPrice(): ?string
    {
        return $this->showroomPrice;
    }

    public function setShowroomPrice(string $showroomPrice): static
    {
        $this->showroomPrice = $showroomPrice;

        return $this;
    }

    public function getWreckValue(): ?string
    {
        return $this->wreckValue;
    }

    public function setWreckValue(string $wreckValue): static
    {
        $this->wreckValue = $wreckValue;

        return $this;
    }

    public function getExcessApplicable(): ?string
    {
        return $this->excessApplicable;
    }

    public function setExcessApplicable(string $excessApplicable): static
    {
        $this->excessApplicable = $excessApplicable;

        return $this;
    }

    public function getCreatedAt(): ?string
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?string $createdAt): static
    {
        $this->createdAt = $createdAt;

        return $this;
    }

    public function getUpdatedAt(): ?string
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?string $updatedAt): static
    {
        $this->updatedAt = $updatedAt;

        return $this;
    }

    public function getVerificationsDraft(): ?VerificationsDraft
    {
        return $this->verificationsDraft;
    }

    public function setVerificationsDraft(?VerificationsDraft $verificationsDraft): static
    {
        $this->verificationsDraft = $verificationsDraft;

        return $this;
    }


}
