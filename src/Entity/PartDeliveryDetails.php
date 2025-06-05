<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * PartDeliveryDetails
 *
 * @ORM\Table(name="part_delivery_details", indexes={@ORM\Index(name="IDX_F506A0C167B3B43D", columns={"users_id"}), @ORM\Index(name="IDX_F506A0C127198996", columns={"repair_parts_id"})})
 * @ORM\Entity
 */
class PartDeliveryDetails
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
     * @var bool|null
     *
     * @ORM\Column(name="is_delivered", type="boolean", nullable=true)
     */
    private $isDelivered;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="delivery_date", type="date", nullable=true)
     */
    private $deliveryDate;

    /**
     * @var bool
     *
     * @ORM\Column(name="satisfactory", type="boolean", nullable=false, options={"default"="1"})
     */
    private $satisfactory = true;

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
     * @var \RepairParts
     *
     * @ORM\ManyToOne(targetEntity="RepairParts")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="repair_parts_id", referencedColumnName="id")
     * })
     */
    private $repairParts;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function isDelivered(): ?bool
    {
        return $this->isDelivered;
    }

    public function setIsDelivered(?bool $isDelivered): static
    {
        $this->isDelivered = $isDelivered;

        return $this;
    }

    public function getDeliveryDate(): ?\DateTime
    {
        return $this->deliveryDate;
    }

    public function setDeliveryDate(?\DateTime $deliveryDate): static
    {
        $this->deliveryDate = $deliveryDate;

        return $this;
    }

    public function isSatisfactory(): ?bool
    {
        return $this->satisfactory;
    }

    public function setSatisfactory(bool $satisfactory): static
    {
        $this->satisfactory = $satisfactory;

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

    public function getUsers(): ?Users
    {
        return $this->users;
    }

    public function setUsers(?Users $users): static
    {
        $this->users = $users;

        return $this;
    }

    public function getRepairParts(): ?RepairParts
    {
        return $this->repairParts;
    }

    public function setRepairParts(?RepairParts $repairParts): static
    {
        $this->repairParts = $repairParts;

        return $this;
    }


}
