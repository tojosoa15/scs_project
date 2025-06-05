<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * DocumentLists
 *
 * @ORM\Table(name="document_lists", indexes={@ORM\Index(name="IDX_6187E9D7388CAFB6", columns={"survey_informations_id"})})
 * @ORM\Entity
 */
class DocumentLists
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
     * @var \SurveyInformations
     *
     * @ORM\ManyToOne(targetEntity="SurveyInformations")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="survey_informations_id", referencedColumnName="id")
     * })
     */
    private $surveyInformations;

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

    public function getSurveyInformations(): ?SurveyInformations
    {
        return $this->surveyInformations;
    }

    public function setSurveyInformations(?SurveyInformations $surveyInformations): static
    {
        $this->surveyInformations = $surveyInformations;

        return $this;
    }


}
