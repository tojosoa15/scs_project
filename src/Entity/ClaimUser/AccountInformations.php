<?php

namespace App\Entity\ClaimUser;

use ApiPlatform\Metadata\Get;
// use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\UserInterface; 
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;


/**
 * AccountInformations
 *
 * @ORM\Table(name="account_informations", uniqueConstraints={@ORM\UniqueConstraint(name="email_address_UNIQUE", columns={"email_address"}), @ORM\UniqueConstraint(name="users_id_UNIQUE", columns={"users_id"})})
 * @ORM\Entity
 */
// #[ApiResource(
//     operations: [
//         // new Get(),
//         // new Post(security: "is_granted('ROLE_ADMIN')"),
//         // denormalizationContext: ['groups' => ['account_information:write']]
//         new Post(
//             uriTemplate: '/api/login',
//             controller: AuthController::class. '::login',
//             // parameters: [ 
//             //     'p_email_address'   => new QueryParameter(),
//             //     'p_password'        => new QueryParameter()
//             // ]
//         )
//     ],
//     // normalizationContext: ['groups' => ['account_information:read']],
// )]


class AccountInformations implements UserInterface, PasswordAuthenticatedUserInterface
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
    private $businessName;

    /**
     * @var string
     *
     * @ORM\Column(name="business_registration_number", type="string", length=150, nullable=false)
     */
    private $businessRegistrationNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="business_address", type="string", length=250, nullable=false)
     */
    private $businessAddress;

    /**
     * @var string
     *
     * @ORM\Column(name="city", type="string", length=45, nullable=false)
     */
    private $city;

    /**
     * @var string
     *
     * @ORM\Column(name="postal_code", type="string", length=45, nullable=false)
     */
    private $postalCode;

    /**
     * @var string
     *
     * @ORM\Column(name="phone_number", type="string", length=100, nullable=false)
     */
    private $phoneNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="email_address", type="string", length=255, nullable=false)
     */
    private $emailAddress;

    /**
     * @var string|null
     *
     * @ORM\Column(name="password", type="string", length=250, nullable=false)
     */
    private $password;

    /**
     * @var string|null
     *
     * @ORM\Column(name="website", type="string", length=150, nullable=true)
     */
    private $website;

    /**
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     * })
     */
    private $users;

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

    public function getUsers(): ?Users
    {
        return $this->users;
    }

    public function setUsers(?Users $users): static
    {
        $this->users = $users;

        return $this;
    }

    public function getRoles(): array
    {
        // Return an array of roles, e.g. ['ROLE_USER']
        return ['ROLE_USER'];
    }

    public function eraseCredentials()
    {   
        // If you store any temporary, sensitive data on the user, clear it here
    }

    public function getUserIdentifier(): string
    {
        // Return the unique identifier for the user (e.g. email)
        return $this->emailAddress;
    }

}
