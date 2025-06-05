<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * RepairParts
 *
 * @ORM\Table(name="repair_parts", indexes={@ORM\Index(name="IDX_C99F63528E6F82E6", columns={"part_details_id"}), @ORM\Index(name="IDX_C99F635267B3B43D", columns={"users_id"}), @ORM\Index(name="IDX_C99F635297DC8098", columns={"rapairs_id"})})
 * @ORM\Entity
 */
class RepairParts
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
     * @var \PartDetails
     *
     * @ORM\ManyToOne(targetEntity="PartDetails")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="part_details_id", referencedColumnName="id")
     * })
     */
    private $partDetails;

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
     * @var \Rapairs
     *
     * @ORM\ManyToOne(targetEntity="Rapairs")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="rapairs_id", referencedColumnName="id")
     * })
     */
    private $rapairs;

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

    public function getPartDetails(): ?PartDetails
    {
        return $this->partDetails;
    }

    public function setPartDetails(?PartDetails $partDetails): static
    {
        $this->partDetails = $partDetails;

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

    public function getRapairs(): ?Rapairs
    {
        return $this->rapairs;
    }

    public function setRapairs(?Rapairs $rapairs): static
    {
        $this->rapairs = $rapairs;

        return $this;
    }


}
