<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * PartDetail
 *
 * @ORM\Table(name="part_detail", indexes={@ORM\Index(name="fk_part_detail_estimate_of_repair1_idx", columns={"estimate_of_repair_id"})})
 * @ORM\Entity
 */
class PartDetail
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
     * @ORM\Column(name="part_name", type="string", length=150, nullable=false)
     */
    private $partName;

    /**
     * @var int
     *
     * @ORM\Column(name="quantity", type="integer", nullable=false)
     */
    private $quantity;

    /**
     * @var string
     *
     * @ORM\Column(name="supplier", type="string", length=255, nullable=false)
     */
    private $supplier;

    /**
     * @var string
     *
     * @ORM\Column(name="quality", type="string", length=45, nullable=false)
     */
    private $quality;

    /**
     * @var float
     *
     * @ORM\Column(name="cost_part", type="float", precision=53, scale=0, nullable=false)
     */
    private $costPart;

    /**
     * @var float
     *
     * @ORM\Column(name="discount_part", type="float", precision=53, scale=0, nullable=false)
     */
    private $discountPart;

    /**
     * @var string
     *
     * @ORM\Column(name="vat", type="string", length=3, nullable=false)
     */
    private $vat;

    /**
     * @var float|null
     *
     * @ORM\Column(name="part_total", type="float", precision=53, scale=0, nullable=true)
     */
    private $partTotal;

    /**
     * @var \EstimateOfRepair
     *
     * @ORM\ManyToOne(targetEntity="EstimateOfRepair")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="estimate_of_repair_id", referencedColumnName="id")
     * })
     */
    private $estimateOfRepair;


}
