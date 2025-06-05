<?php

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * Rapairs
 *
 * @ORM\Table(name="rapairs", indexes={@ORM\Index(name="IDX_CC787977C4FFF555", columns={"garage_id"}), @ORM\Index(name="IDX_CC78797787B1A554", columns={"claims_id"})})
 * @ORM\Entity
 */
class Rapairs
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
     * @ORM\Column(name="appointement_date", type="date", nullable=true)
     */
    private $appointementDate;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="appointement_time", type="time", nullable=true)
     */
    private $appointementTime;

    /**
     * @var string|null
     *
     * @ORM\Column(name="swan_claim_handler", type="string", length=150, nullable=true)
     */
    private $swanClaimHandler;

    /**
     * @var string|null
     *
     * @ORM\Column(name="remarks", type="text", length=16, nullable=true)
     */
    private $remarks;

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
     *   @ORM\JoinColumn(name="garage_id", referencedColumnName="id")
     * })
     */
    private $garage;

    /**
     * @var \Claims
     *
     * @ORM\ManyToOne(targetEntity="Claims")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="claims_id", referencedColumnName="id")
     * })
     */
    private $claims;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAppointementDate(): ?\DateTime
    {
        return $this->appointementDate;
    }

    public function setAppointementDate(?\DateTime $appointementDate): static
    {
        $this->appointementDate = $appointementDate;

        return $this;
    }

    public function getAppointementTime(): ?\DateTime
    {
        return $this->appointementTime;
    }

    public function setAppointementTime(?\DateTime $appointementTime): static
    {
        $this->appointementTime = $appointementTime;

        return $this;
    }

    public function getSwanClaimHandler(): ?string
    {
        return $this->swanClaimHandler;
    }

    public function setSwanClaimHandler(?string $swanClaimHandler): static
    {
        $this->swanClaimHandler = $swanClaimHandler;

        return $this;
    }

    public function getRemarks(): ?string
    {
        return $this->remarks;
    }

    public function setRemarks(?string $remarks): static
    {
        $this->remarks = $remarks;

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

    public function getGarage(): ?Users
    {
        return $this->garage;
    }

    public function setGarage(?Users $garage): static
    {
        $this->garage = $garage;

        return $this;
    }

    public function getClaims(): ?Claims
    {
        return $this->claims;
    }

    public function setClaims(?Claims $claims): static
    {
        $this->claims = $claims;

        return $this;
    }


}
