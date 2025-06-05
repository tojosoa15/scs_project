<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * AdministrativeSettings
 *
 * @ORM\Table(name="administrative_settings", uniqueConstraints={@ORM\UniqueConstraint(name="UQ_administrative_settings_users_id", columns={"users_id"})})
 * @ORM\Entity
 */
class AdministrativeSettings
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
     * @ORM\Column(name="primary_contact_name", type="string", length=255, nullable=false)
     */
    private $primaryContactName;

    /**
     * @var string
     *
     * @ORM\Column(name="primary_contact_post", type="string", length=150, nullable=false)
     */
    private $primaryContactPost;

    /**
     * @var string
     *
     * @ORM\Column(name="notification", type="string", length=-1, nullable=false)
     */
    private $notification;

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
     * @var \Doctrine\Common\Collections\Collection
     *
     * @ORM\ManyToMany(targetEntity="CommunicationMethods", inversedBy="administrativeSettings")
     * @ORM\JoinTable(name="admin_settings_communications",
     *   joinColumns={
     *     @ORM\JoinColumn(name="admin_settings_id", referencedColumnName="id")
     *   },
     *   inverseJoinColumns={
     *     @ORM\JoinColumn(name="method_id", referencedColumnName="id")
     *   }
     * )
     */
    private $communicationMethods = array();

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPrimaryContactName(): ?string
    {
        return $this->primaryContactName;
    }

    public function setPrimaryContactName(string $primaryContactName): static
    {
        $this->primaryContactName = $primaryContactName;

        return $this;
    }

    public function getPrimaryContactPost(): ?string
    {
        return $this->primaryContactPost;
    }

    public function setPrimaryContactPost(string $primaryContactPost): static
    {
        $this->primaryContactPost = $primaryContactPost;

        return $this;
    }

    public function getNotification(): ?string
    {
        return $this->notification;
    }

    public function setNotification(string $notification): static
    {
        $this->notification = $notification;

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


}
