<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * DraftRepairParts
 *
 * @ORM\Table(name="draft_repair_parts", indexes={@ORM\Index(name="IDX_A36E788F67B3B43D", columns={"users_id"}), @ORM\Index(name="IDX_A36E788F68B22DFF", columns={"draft_part_details_id"}), @ORM\Index(name="IDX_A36E788F5243E495", columns={"rapairs_draft_id"})})
 * @ORM\Entity
 */
class DraftRepairParts
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
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     * })
     */
    private $users;

    /**
     * @var \DraftPartDetails
     *
     * @ORM\ManyToOne(targetEntity="DraftPartDetails")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="draft_part_details_id", referencedColumnName="id")
     * })
     */
    private $draftPartDetails;

    /**
     * @var \RapairsDraft
     *
     * @ORM\ManyToOne(targetEntity="RapairsDraft")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="rapairs_draft_id", referencedColumnName="id")
     * })
     */
    private $rapairsDraft;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getUsers(): ?Users
    {
        return $this->users;
    }

    public function setUsers(?Users $users): static
    {
        $this->users = $users;

        return $this;
    }

    public function getDraftPartDetails(): ?DraftPartDetails
    {
        return $this->draftPartDetails;
    }

    public function setDraftPartDetails(?DraftPartDetails $draftPartDetails): static
    {
        $this->draftPartDetails = $draftPartDetails;

        return $this;
    }

    public function getRapairsDraft(): ?RapairsDraft
    {
        return $this->rapairsDraft;
    }

    public function setRapairsDraft(?RapairsDraft $rapairsDraft): static
    {
        $this->rapairsDraft = $rapairsDraft;

        return $this;
    }


}
