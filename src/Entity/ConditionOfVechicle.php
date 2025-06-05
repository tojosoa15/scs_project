<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * ConditionOfVechicle
 *
 * @ORM\Table(name="condition_of_vechicle", uniqueConstraints={@ORM\UniqueConstraint(name="UQ_condition_name", columns={"condition_name"}), @ORM\UniqueConstraint(name="UQ_condition_code", columns={"condition_code"})})
 * @ORM\Entity
 */
class ConditionOfVechicle
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
     * @ORM\Column(name="condition_code", type="string", length=45, nullable=false)
     */
    private $conditionCode;

    /**
     * @var string
     *
     * @ORM\Column(name="condition_name", type="string", length=45, nullable=false)
     */
    private $conditionName;

    /**
     * @var string|null
     *
     * @ORM\Column(name="description", type="text", length=16, nullable=true)
     */
    private $description;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updatedAt = 'CURRENT_TIMESTAMP';

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getConditionCode(): ?string
    {
        return $this->conditionCode;
    }

    public function setConditionCode(string $conditionCode): static
    {
        $this->conditionCode = $conditionCode;

        return $this;
    }

    public function getConditionName(): ?string
    {
        return $this->conditionName;
    }

    public function setConditionName(string $conditionName): static
    {
        $this->conditionName = $conditionName;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;

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


}
