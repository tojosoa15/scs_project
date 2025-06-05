<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * DraftDocumentLists
 *
 * @ORM\Table(name="draft_document_lists", indexes={@ORM\Index(name="IDX_DF74F198A0F1709C", columns={"draft_survey_informations_id"})})
 * @ORM\Entity
 */
class DraftDocumentLists
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
     * @var \DraftSurveyInformations
     *
     * @ORM\ManyToOne(targetEntity="DraftSurveyInformations")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_survey_informations_id", referencedColumnName="id")
     * })
     */
    private $draftSurveyInformations;

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

    public function getDraftSurveyInformations(): ?DraftSurveyInformations
    {
        return $this->draftSurveyInformations;
    }

    public function setDraftSurveyInformations(?DraftSurveyInformations $draftSurveyInformations): static
    {
        $this->draftSurveyInformations = $draftSurveyInformations;

        return $this;
    }


}
