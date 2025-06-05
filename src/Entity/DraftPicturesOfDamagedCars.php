<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * DraftPicturesOfDamagedCars
 *
 * @ORM\Table(name="draft_pictures_of_damaged_cars", indexes={@ORM\Index(name="IDX_3D18F2EFA0F1709C", columns={"draft_survey_informations_id"})})
 * @ORM\Entity
 */
class DraftPicturesOfDamagedCars
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
     * @ORM\Column(name="path", type="string", length=255, nullable=true)
     */
    private $path;

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

    public function getPath(): ?string
    {
        return $this->path;
    }

    public function setPath(?string $path): static
    {
        $this->path = $path;

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
