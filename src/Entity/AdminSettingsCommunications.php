<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * AdminSettingsCommunications
 *
 * @ORM\Table(name="admin_settings_communications", indexes={@ORM\Index(name="IDX_42D45B4519883967", columns={"method_id"})})
 * @ORM\Entity
 */
class AdminSettingsCommunications
{
    /**
     * @var int
     *
     * @ORM\Column(name="user_id", type="integer", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="NONE")
     */
    private $adminSettings;

    /**
     * @var bool|null
     *
     * @ORM\Column(name="is_active", type="boolean", nullable=true, options={"default"="1"})
     */
    private $isActive = true;

    /**
     * @var \CommunicationMethods
     *
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="NONE")
     * @ORM\OneToOne(targetEntity="CommunicationMethods")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="method_id", referencedColumnName="id")
     * })
     */
    private $method;

    public function getAdminSettings(): ?int
    {
        return $this->adminSettings;
    }

    public function isActive(): ?bool
    {
        return $this->isActive;
    }

    public function setIsActive(?bool $isActive): static
    {
        $this->isActive = $isActive;

        return $this;
    }

    public function getMethod(): ?CommunicationMethods
    {
        return $this->method;
    }

    public function setMethod(?CommunicationMethods $method): static
    {
        $this->method = $method;

        return $this;
    }


}
