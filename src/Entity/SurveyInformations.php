<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * SurveyInformations
 *
 * @ORM\Table(name="survey_informations", uniqueConstraints={@ORM\UniqueConstraint(name="UQ_verifications_id", columns={"verifications_id"})})
 * @ORM\Entity
 */
// #[ApiResource(
//     normalizationContext: ['groups' => ['survey_info:read']],
//     denormalizationContext: ['groups' => ['survey_info:write']]
// )]
class SurveyInformations
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
    #[Groups(['verification:read', 'verification:write', 'survey_info:read', 'survey_info:write'])]
    private $garage;

    /**
     * @var string
     *
     * @ORM\Column(name="garage_address", type="string", length=255, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $garageAddress;

    /**
     * @var string
     *
     * @ORM\Column(name="garage_contact_number", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $garageContactNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="eor_value", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $eorValue;

    /**
     * @var string
     *
     * @ORM\Column(name="invoice_number", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $invoiceNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="survey_type", type="string", length=45, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $surveyType;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="date_of_survey", type="date", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $dateOfSurvey;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="time_of_survey", type="time", nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $timeOfSurvey;

    /**
     * @var string
     *
     * @ORM\Column(name="pre_accident_value", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $preAccidentValue;

    /**
     * @var string
     *
     * @ORM\Column(name="showroom_price", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $showroomPrice;

    /**
     * @var string
     *
     * @ORM\Column(name="wreck_value", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
    private $wreckValue;

    /**
     * @var string
     *
     * @ORM\Column(name="excess_applicable", type="decimal", precision=10, scale=2, nullable=false)
     */
    #[Groups(groups: ['verification:write', 'verification:read'])]
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
     * @var \Verifications
     *
     * @ORM\ManyToOne(targetEntity="Verifications")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verifications_id", referencedColumnName="id")
     * })
     */
    private $verifications;

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

    public function getVerifications(): ?Verifications
    {
        return $this->verifications;
    }

    public function setVerifications(?Verifications $verifications): static
    {
        $this->verifications = $verifications;

        return $this;
    }


}
