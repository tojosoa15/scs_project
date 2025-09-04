<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * NavFunds
 *
 * @ORM\Table(name="nav_funds")
 * @ORM\Entity
 */
class NavFunds
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
     * @ORM\Column(name="code_name", type="string", length=45, nullable=false)
     */
    private $codeName;

    /**
     * @var string
     *
     * @ORM\Column(name="type_nav", type="string", length=45, nullable=false)
     */
    private $typeNav;

    /**
     * @var float
     *
     * @ORM\Column(name="value", type="float", precision=10, scale=0, nullable=false)
     */
    private $value;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCodeName(): ?string
    {
        return $this->codeName;
    }

    public function setCodeName(string $codeName): static
    {
        $this->codeName = $codeName;

        return $this;
    }

    public function getTypeNav(): ?string
    {
        return $this->typeNav;
    }

    public function setTypeNav(string $typeNav): static
    {
        $this->typeNav = $typeNav;

        return $this;
    }

    public function getValue(): ?float
    {
        return $this->value;
    }

    public function setValue(float $value): static
    {
        $this->value = $value;

        return $this;
    }


}
