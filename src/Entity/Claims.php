<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Delete;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * Claims
 *
 * @ORM\Table(name="claims")
 * @ORM\Entity
 */
// #[ApiResource(
//     operations: [
//         new GetCollection(
//             normalizationContext: ['groups' => ['claim:read']],
//         ),
//         new Post(
//             denormalizationContext: ['groups' => ['claim:write']],
//             validationContext: ['groups' => ['claim:write']]
//         ),
//         new Get(
//             normalizationContext: ['groups' => ['claim:read']]
//         ),
//         new Patch(),
//         new Delete()
//     ]
// )]
class Claims
{
    /**
     * @var int
     *
     * @ORM\Column(name="id", type="integer", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="IDENTITY")
     */
    #[Groups(['verification:read', 'claim:read'])]
    private $id;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="received_date", type="date", nullable=false, options={"default"="CONVERT([date],getdate())"})
     */
    #[Groups(['claim:read'])]
    private $receivedDate = 'CONVERT([date],getdate())';

    /**
     * @var string
     *
     * @ORM\Column(name="number", type="string", length=255, nullable=false)
     */
    #[Groups(['verification:read', 'claim:read'])]
    private $number;

    /**
     * @var string
     *
     * @ORM\Column(name="name", type="string", length=45, nullable=false)
     */
    #[Groups(['claim:read'])]
    private $name;

    /**
     * @var string
     *
     * @ORM\Column(name="registration_number", type="string", length=45, nullable=false)
     */
    #[Groups(['claim:read'])]
    private $registrationNumber;

    /**
     * @var int
     *
     * @ORM\Column(name="ageing", type="integer", nullable=false)
     */
    #[Groups(['claim:read'])]
    private $ageing;

    /**
     * @var string
     *
     * @ORM\Column(name="phone", type="string", length=255, nullable=false)
     */
    #[Groups(['claim:read'])]
    private $phone;

    /**
     * @var \Status
     *
     * @ORM\ManyToOne(targetEntity="Status")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="status", referencedColumnName="id")
     * })
     */
    #[Groups(['claim:read'])]
    private ?Status $status = null;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $createdAt = null;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updatedAt = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getReceivedDate(): ?\DateTime
    {
        return $this->receivedDate;
    }

    public function setReceivedDate(\DateTime $receivedDate): static
    {
        $this->receivedDate = $receivedDate;;

        return $this;
    }

    public function getNumber(): ?string
    {
        return $this->number;
    }

    public function setNumber(string $number): static
    {
        $this->number = $number;

        return $this;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;

        return $this;
    }

    public function getRegistrationNumber(): ?string
    {
        return $this->registrationNumber;
    }

    public function setRegistrationNumber(string $registrationNumber): static
    {
        $this->registrationNumber = $registrationNumber;

        return $this;
    }

    public function getAgeing(): ?int
    {
        return $this->ageing;
    }

    public function setAgeing(int $ageing): static
    {
        $this->ageing = $ageing;

        return $this;
    }

    public function getPhone(): ?string
    {
        return $this->phone;
    }

    public function setPhone(string $phone): static
    {
        $this->phone = $phone;

        return $this;
    }

    public function getStatus(): ?Status
    {
        return $this->status;
    }

    public function setStatus(?Status $status): static
    {
        $this->status = $status;

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


}
