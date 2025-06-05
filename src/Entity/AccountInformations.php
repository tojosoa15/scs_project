<?php

namespace App\Entity;

use App\Entity\Users;
use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\QueryParameter;
use Doctrine\ORM\Mapping as ORM;
// use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * 
 * 

 *
 * @ORM\Table(name="account_informations", uniqueConstraints={@ORM\UniqueConstraint(name="UQ_account_informations_users_id", columns={"users_id"}), @ORM\UniqueConstraint(name="UQ_account_informations_email_address", columns={"email_address"})})
 * @ORM\Entity
 */
// #[ApiResource(
//     operations: [
//         new GetCollection(
//             normalizationContext: ['groups' => ['account:read']],
//         ),
//         new GetCollection(
//             uriTemplate: '/profile/users',
//             parameters: ['id' => new QueryParameter(), 'email' => new QueryParameter()],
//             controller: GetUserAccountInformationsController::class,
//         ),
//         new Post(
//             denormalizationContext: ['groups' => ['account:write']],
//             validationContext: ['groups' => ['account:write']]
//         ),
//         new Get(
//             normalizationContext: ['groups' => ['account:read']]
//         ),
//         new Patch(),
//         new Delete()
//     ]
// )]
class AccountInformations
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
     * @ORM\Column(name="business_name", type="string", length=150, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $businessName;

    /**
     * @var string
     *
     * @ORM\Column(name="business_registration_number", type="string", length=150, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $businessRegistrationNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="business_address", type="string", length=250, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $businessAddress;

    /**
     * @var string
     *
     * @ORM\Column(name="city", type="string", length=45, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $city;

    /**
     * @var string
     *
     * @ORM\Column(name="postal_code", type="string", length=45, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $postalCode;

    /**
     * @var string
     *
     * @ORM\Column(name="phone_number", type="string", length=100, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $phoneNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="email_address", type="string", length=255, nullable=false)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $emailAddress;

    /**
     * @var string|null
     *
     * @ORM\Column(name="password", type="string", length=250, nullable=true)
     */
    #[Groups(['user:write'])]
    private ?string $password = null;

    /**
     * @var string|null
     *
     * @ORM\Column(name="website", type="string", length=150, nullable=true)
     */
    #[Groups(['user:read', 'user:write', 'account:read'])]
    private $website;


    /**
     * @var Users|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\Users", inversedBy="accountInformation")
     * @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     */
     #[Groups(['account:read'])]
    private ?Users $users = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getBusinessName(): ?string
    {
        return $this->businessName;
    }

    public function setBusinessName(string $businessName): static
    {
        $this->businessName = $businessName;

        return $this;
    }

    public function getBusinessRegistrationNumber(): ?string
    {
        return $this->businessRegistrationNumber;
    }

    public function setBusinessRegistrationNumber(string $businessRegistrationNumber): static
    {
        $this->businessRegistrationNumber = $businessRegistrationNumber;

        return $this;
    }

    public function getBusinessAddress(): ?string
    {
        return $this->businessAddress;
    }

    public function setBusinessAddress(string $businessAddress): static
    {
        $this->businessAddress = $businessAddress;

        return $this;
    }

    public function getCity(): ?string
    {
        return $this->city;
    }

    public function setCity(string $city): static
    {
        $this->city = $city;

        return $this;
    }

    public function getPostalCode(): ?string
    {
        return $this->postalCode;
    }

    public function setPostalCode(string $postalCode): static
    {
        $this->postalCode = $postalCode;

        return $this;
    }

    public function getPhoneNumber(): ?string
    {
        return $this->phoneNumber;
    }

    public function setPhoneNumber(string $phoneNumber): static
    {
        $this->phoneNumber = $phoneNumber;

        return $this;
    }

    public function getEmailAddress(): ?string
    {
        return $this->emailAddress;
    }

    public function setEmailAddress(string $emailAddress): static
    {
        $this->emailAddress = $emailAddress;

        return $this;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

    public function setPassword(?string $password): static
    {
        $this->password = $password;

        return $this;
    }

    public function getWebsite(): ?string
    {
        return $this->website;
    }

    public function setWebsite(?string $website): static
    {
        $this->website = $website;

        return $this;
    }

    // public function getUsers(): ?Users
    // {
    //     return $this->users;
    // }

    // public function setUsers(?Users $users): static
    // {
    //     $this->users = $users;

    //     return $this;
    // }
    public function getUsers(): ?Users
    {
        return $this->users;
    }

    public function setUsers(?Users $users): self
    {
        // Nettoyage de l'ancienne relation
        if ($this->users !== null && $this->users->getAccountInformation() === $this) {
            $this->users->setAccountInformation(null);
        }

        // Mise à jour de la nouvelle relation
        $this->users = $users;

        // Définition de la relation inverse
        if ($users !== null && $users->getAccountInformation() !== $this) {
            $users->setAccountInformation($this);
        }

        return $this;
    }

}
