<?php

namespace App\Entity\Surveyor;

use Doctrine\ORM\Mapping as ORM;

/**
 * Documents
 *
 * @ORM\Table(name="documents", indexes={@ORM\Index(name="fk_documents_survey_information1_idx", columns={"survey_information_id"})})
 * @ORM\Entity
 */
class Documents
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
     * @ORM\Column(name="attachements", type="string", length=255, nullable=true)
     */
    private $attachements;

    /**
     * @var \SurveyInformation
     *
     * @ORM\ManyToOne(targetEntity="SurveyInformation")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="survey_information_id", referencedColumnName="id")
     * })
     */
    private $surveyInformation;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAttachements(): ?string
    {
        return $this->attachements;
    }

    public function setAttachements(?string $attachements): static
    {
        $this->attachements = $attachements;

        return $this;
    }

    public function getSurveyInformation(): ?SurveyInformation
    {
        return $this->surveyInformation;
    }

    public function setSurveyInformation(?SurveyInformation $surveyInformation): static
    {
        $this->surveyInformation = $surveyInformation;

        return $this;
    }


}
