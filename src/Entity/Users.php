<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\QueryParameter;
use App\Repository\UsersRepository;
use Doctrine\Common\Collections\Collection;
use App\Controller\GetClaimsByUserController;
use App\Controller\GetListUtilisateurController;
use App\Controller\GetProfilUserController;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * Users
 *
 * @ORM\Table(name="users")
 * @ORM\Entity
 */
#[ApiResource(
    operations: [
        // new GetCollection(
        //     normalizationContext: ['groups' => ['user:read']]
        // ),
        // Profile utilisateur
         new GetCollection(
            uriTemplate: '/profile/users',
            parameters: ['userId' => new QueryParameter(), 'email' => new QueryParameter()],
            controller: GetProfilUserController::class,
        ),
        // Liste utilisateur avec rôles
        new GetCollection(
            uriTemplate: '/list_users/with_roles',
            controller: GetListUtilisateurController::class,
            parameters: ['role' => new QueryParameter()],
        ),
        // Liste claim d'un utilisateur
        new GetCollection(
            uriTemplate: '/list_claims/by_user',
            controller: GetClaimsByUserController::class,
            parameters: [ 'email' => new QueryParameter()],
        ),
        // new Post(
        //     denormalizationContext: ['groups' => ['user:write']],
        //     validationContext: ['groups' => ['user:write']]
        // ),
        // new Get(
        //     normalizationContext: ['groups' => ['user:read']]
        // ),
        // new Patch(),
        // new Delete()
    ]
)]
#[ORM\Entity(repositoryClass: UsersRepository::class)]
class Users
{
    /**
     * @var int
     *
     * @ORM\Column(name="id", type="integer", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="IDENTITY")
     */
    #[Groups(['user:read', 'account:read'])]
    private $id;

    //  /**
    //  * @ORM\Column(name="created_at", type="datetime", nullable=true)
    //  */
    // private ?\DateTimeInterface $createdAt = null;

    // /**
    //  * @ORM\Column(name="updated_at", type="datetime", nullable=true)
    //  */
    // private ?\DateTimeInterface $updatedAt = null;

    /**
     * @var \Doctrine\Common\Collections\Collection
     *
     * @ORM\ManyToMany(targetEntity="Roles", inversedBy="users")
     * @ORM\JoinTable(name="user_roles",
     *   joinColumns={
     *     @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     *   },
     *   inverseJoinColumns={
     *     @ORM\JoinColumn(name="roles_id", referencedColumnName="id")
     *   }
     * )
     */
    #[Groups(['user:read', 'user:write'])]
    private $roles = array();

    /**
     * @var AccountInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\AccountInformations", mappedBy="users", cascade={"persist", "remove"})
     */
    #[Groups(['user:read', 'user:write'])]
    private ?AccountInformations $accountInformation = null;

    /**
     * @var FinancialInformations|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\FinancialInformations", mappedBy="users", cascade={"persist", "remove"})
     */
    #[Groups(['user:read', 'user:write'])]
    private ?FinancialInformations $financialInformation = null;

    /**
     * @var AdministrativeSettings|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\AdministrativeSettings", mappedBy="users", cascade={"persist", "remove"})
     */
    #[Groups(['user:read', 'user:write'])]
    private ?AdministrativeSettings $administrativeSettings = null;

    /**
     * Constructor
     */
    public function __construct()
    {
        $this->roles = new \Doctrine\Common\Collections\ArrayCollection();
        // $this->createdAt = new \DateTime(); // Initialise avec la date courante
        // $this->updatedAt = new \DateTime(); // Initialise avec la date courante
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    // public function getCreatedAt(): ?\DateTime
    // {
    //     return $this->createdAt;
    // }

    // public function setCreatedAt(?\DateTime $createdAt): static
    // {
    //     $this->createdAt = $createdAt;

    //     return $this;
    // }

    //  /**
    //  * @ORM\PrePersist
    //  */
    // public function setCreatedAtValue(): void
    // {
    //     // $this->createdAt = new \DateTime();
    //     // $this->updatedAt = new \DateTime();
    //     if ($this->createdAt === null) {
    //         $this->createdAt = new \DateTime();
    //     }
    //     $this->updatedAt = new \DateTime();
    // }

    // public function getUpdatedAt(): ?\DateTime
    // {
    //     return $this->updatedAt;
    // }

    // /**
    //  * @ORM\PreUpdate
    //  */
    // public function setUpdatedAtValue(): void
    // {
    //     $this->updatedAt = new \DateTime();
    // }


    /**
     * @return Collection<int, Roles>
     */
    public function getRoles(): Collection
    {
        return $this->roles;
    }

    public function addRole(Roles $role): static
    {
        if (!$this->roles->contains($role)) {
            $this->roles->add($role);
        }

        return $this;
    }

    public function removeRole(Roles $role): static
    {
        $this->roles->removeElement($role);

        return $this;
    }

    // Pour la relation account information
    public function getAccountInformation(): ?AccountInformations
    {
        return $this->accountInformation;
    }

    public function setAccountInformation(?AccountInformations $accountInformation): self
    {
        // On évite les boucles infinies
        if ($this->accountInformation === $accountInformation) {
            return $this;
        }

        // On nettoie l'ancienne relation
        if ($this->accountInformation !== null) {
            $temp = $this->accountInformation;
            $this->accountInformation = null;
            $temp->setUsers(null);
        }

        // On définit la nouvelle relation
        $this->accountInformation = $accountInformation;

        // On définit la relation inverse
        if ($accountInformation !== null) {
            $accountInformation->setUsers($this);
        }

        return $this;
    }

    // Pour la relation financial information
    public function getFinancialInformation(): ?FinancialInformations
    {
        return $this->financialInformation;
    }

    public function setFinancialInformation(?FinancialInformations $financialInformation): self
    {
        // On évite les boucles infinies
        if ($this->financialInformation === $financialInformation) {
            return $this;
        }

        // On nettoie l'ancienne relation
        if ($this->financialInformation !== null) {
            $temp = $this->financialInformation;
            $this->financialInformation = null;
            $temp->setUsers(null);
        }

        // On définit la nouvelle relation
        $this->financialInformation = $financialInformation;

        // On définit la relation inverse
        if ($financialInformation !== null) {
            $financialInformation->setUsers($this);
        }

        return $this;
    }

}
