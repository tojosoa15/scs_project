<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * LabourDetail
 *
 * @ORM\Table(name="labour_detail", indexes={@ORM\Index(name="fk_labour_detail_part_detail1_idx", columns={"part_detail_id"})})
 * @ORM\Entity
 */
class LabourDetail
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
     * @ORM\Column(name="eor_or_surveyor", type="string", length=10, nullable=false)
     */
    private $eorOrSurveyor;

    /**
     * @var string
     *
     * @ORM\Column(name="activity", type="string", length=45, nullable=false)
     */
    private $activity;

    /**
     * @var int
     *
     * @ORM\Column(name="number_of_hours", type="integer", nullable=false)
     */
    private $numberOfHours;

    /**
     * @var float
     *
     * @ORM\Column(name="hourly_const_labour", type="float", precision=53, scale=0, nullable=false)
     */
    private $hourlyConstLabour;

    /**
     * @var float
     *
     * @ORM\Column(name="discount_labour", type="float", precision=53, scale=0, nullable=false)
     */
    private $discountLabour;

    /**
     * @var string
     *
     * @ORM\Column(name="vat", type="string", length=3, nullable=false)
     */
    private $vat;

    /**
     * @var float|null
     *
     * @ORM\Column(name="labour_total", type="float", precision=53, scale=0, nullable=true)
     */
    private $labourTotal;

    /**
     * @var \PartDetail
     *
     * @ORM\ManyToOne(targetEntity="PartDetail")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="part_detail_id", referencedColumnName="id")
     * })
     */
    private $partDetail;


}
