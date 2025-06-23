<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * AdditionalLabourDetail
 *
 * @ORM\Table(name="additional_labour_detail", indexes={@ORM\Index(name="fk_additional_labour_detail_estimate_of_repairs1_idx", columns={"estimate_of_repair_id"})})
 * @ORM\Entity
 */
class AdditionalLabourDetail
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
     * @var float
     *
     * @ORM\Column(name="painting_cost", type="float", precision=53, scale=0, nullable=false)
     */
    private $paintingCost;

    /**
     * @var float
     *
     * @ORM\Column(name="painting_materiels", type="float", precision=53, scale=0, nullable=false)
     */
    private $paintingMateriels;

    /**
     * @var float
     *
     * @ORM\Column(name="sundries", type="float", precision=53, scale=0, nullable=false)
     */
    private $sundries;

    /**
     * @var int
     *
     * @ORM\Column(name="num_of_repaire_days", type="integer", nullable=false)
     */
    private $numOfRepaireDays;

    /**
     * @var float
     *
     * @ORM\Column(name="discount_add_labour", type="float", precision=53, scale=0, nullable=false)
     */
    private $discountAddLabour;

    /**
     * @var string
     *
     * @ORM\Column(name="vat", type="string", length=3, nullable=false)
     */
    private $vat;

    /**
     * @var float|null
     *
     * @ORM\Column(name="add_labour_total", type="float", precision=53, scale=0, nullable=true)
     */
    private $addLabourTotal;

    /**
     * @var string|null
     *
     * @ORM\Column(name="eor_or_surveyor", type="string", length=10, nullable=true)
     */
    private $eorOrSurveyor;

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
