<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiFilter;
use ApiPlatform\Doctrine\Orm\Filter\SearchFilter;
use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\QueryParameter;
use App\Controller\ExportListPayementController;
use App\Controller\ListPayementsUsersController;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

/**
 * Payements
 *
 * @ORM\Table(name="payements", indexes={@ORM\Index(name="fk_payements_status1_idx", columns={"status_id"})})
 * @ORM\Entity
 */
#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/list_payement/users',
            parameters: [
                'userId'        => new QueryParameter(),
                'claimNo'       => new QueryParameter(),
                'status'        => new QueryParameter(),
                'invoiceNo'     => new QueryParameter(),
                'dateSubmited'  => new QueryParameter(),
                'payementDate'  => new QueryParameter(),
            ],
            controller: ListPayementsUsersController::class,
        ),
        new GetCollection(
            uriTemplate: '/export_payement/users',
            parameters: [
                'userId'            => new QueryParameter(),
                'typeExport'        => new QueryParameter(),
                'startDateSubmited' => new QueryParameter(),
                'endDateSubmited'   => new QueryParameter(),
                'dateSubmitted'     => new QueryParameter(),
                'claimNo'           => new QueryParameter(),
                'status'            => new QueryParameter(),
                'invoiceNo'         => new QueryParameter(),
                'payementDate'      => new QueryParameter(),
            ],
            controller: ExportListPayementController::class,
        )
    ]
)]
class Payements
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
     * @ORM\Column(name="date_submitted", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $dateSubmitted = 'CURRENT_TIMESTAMP';

    /**
     * @var string|null
     *
     * @ORM\Column(name="invoice_num", type="string", length=45, nullable=true)
     */
    private $invoiceNum;

    /**
     * @var string|null
     *
     * @ORM\Column(name="claim_num", type="string", length=45, nullable=true)
     */
    private $claimNum;

    /**
     * @var string|null
     *
     * @ORM\Column(name="claim_amount", type="decimal", precision=20, scale=2, nullable=true)
     */
    private $claimAmount;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="payement_date", type="datetime", nullable=true)
     */
    private $payementDate;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $createdAt = null; // 'CURRENT_TIMESTAMP';

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="updated_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updatedAt = null; // 'CURRENT_TIMESTAMP';

    /**
     * @var \Status
     *
     * @ORM\ManyToOne(targetEntity="Status")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="status_id", referencedColumnName="id")
     * })
     */
    private ?Status $status = null;

    /**
     * @var \Users
     *
     * @ORM\ManyToOne(targetEntity="Users")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="users_id", referencedColumnName="id")
     * })
     */
    private ?Users $users = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDateSubmitted(): ?\DateTime
    {
        return $this->dateSubmitted;
    }

    public function setDateSubmitted(?\DateTime $dateSubmitted): static
    {
        $this->dateSubmitted = $dateSubmitted;

        return $this;
    }

    public function getInvoiceNum(): ?string
    {
        return $this->invoiceNum;
    }

    public function setInvoiceNum(?string $invoiceNum): static
    {
        $this->invoiceNum = $invoiceNum;

        return $this;
    }

    public function getClaimNum(): ?string
    {
        return $this->claimNum;
    }

    public function setClaimNum(?string $claimNum): static
    {
        $this->claimNum = $claimNum;

        return $this;
    }

    public function getClaimAmount(): ?string
    {
        return $this->claimAmount;
    }

    public function setClaimAmount(?string $claimAmount): static
    {
        $this->claimAmount = $claimAmount;

        return $this;
    }

    public function getPayementDate(): ?\DateTime
    {
        return $this->payementDate;
    }

    public function setPayementDate(?\DateTime $payementDate): static
    {
        $this->payementDate = $payementDate;

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

    public function getStatus(): ?Status
    {
        return $this->status;
    }

    public function setStatus(?Status $status): static
    {
        $this->status = $status;

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
