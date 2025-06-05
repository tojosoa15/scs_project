<?php

namespace App\Entity;

use App\Entity\Users;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * FinancialInformations
 *
 * @ORM\Table(name="financial_informations", uniqueConstraints={@ORM\UniqueConstraint(name="UQ_financial_informations_users_id", columns={"users_id"})})
 * @ORM\Entity
 */
class FinancialInformations
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
     * @ORM\Column(name="vat_number", type="string", length=255, nullable=false)
     */
    #[Groups(['user:read', 'user:write'])]
    private $vatNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="tax_identification_number", type="string", length=255, nullable=false)
     */
    #[Groups(['user:read', 'user:write'])]
    private $taxIdentificationNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="bank_name", type="string", length=150, nullable=false)
     */
    #[Groups(['user:read', 'user:write'])]
    private $bankName;

    /**
     * @var int
     *
     * @ORM\Column(name="bank_account_number", type="bigint", nullable=false)
     */
    #[Groups(['user:read', 'user:write'])]
    private $bankAccountNumber;

    /**
     * @var string
     *
     * @ORM\Column(name="swift_code", type="string", length=255, nullable=false)
     */
    #[Groups(['user:read', 'user:write'])]
    private $swiftCode;

    // /**
    //  * @var \Users
    //  *
    //  * @ORM\ManyToOne(targetEntity="App\Entity\Users", inversedBy="financialInformation")
    //  * @ORM\JoinColumns({
    //  *   @ORM\JoinColumn(name="users_id", referencedColumnName="id")
    //  * })
    //  */
    // private $users;
    /**
     * @var Users|null
     *
     * @ORM\OneToOne(targetEntity="App\Entity\Users", inversedBy="financialInformation")
     * @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     */
    private ?Users $users = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getVatNumber(): ?string
    {
        return $this->vatNumber;
    }

    public function setVatNumber(string $vatNumber): static
    {
        $this->vatNumber = $vatNumber;

        return $this;
    }

    public function getTaxIdentificationNumber(): ?string
    {
        return $this->taxIdentificationNumber;
    }

    public function setTaxIdentificationNumber(string $taxIdentificationNumber): static
    {
        $this->taxIdentificationNumber = $taxIdentificationNumber;

        return $this;
    }

    public function getBankName(): ?string
    {
        return $this->bankName;
    }

    public function setBankName(string $bankName): static
    {
        $this->bankName = $bankName;

        return $this;
    }

    public function getBankAccountNumber(): ?string
    {
        return $this->bankAccountNumber;
    }

    public function setBankAccountNumber(string $bankAccountNumber): static
    {
        $this->bankAccountNumber = $bankAccountNumber;

        return $this;
    }

    public function getSwiftCode(): ?string
    {
        return $this->swiftCode;
    }

    public function setSwiftCode(string $swiftCode): static
    {
        $this->swiftCode = $swiftCode;

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
        if ($this->users !== null && $this->users->getFinancialInformation() === $this) {
            $this->users->setFinancialInformation(null);
        }

        // Mise à jour de la nouvelle relation
        $this->users = $users;

        // Définition de la relation inverse
        if ($users !== null && $users->getFinancialInformation() !== $this) {
            $users->setFinancialInformation($this);
        }

        return $this;
    }


}
