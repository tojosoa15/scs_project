<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * EstimateOfRepair
 *
 * @ORM\Table(name="estimate_of_repair", indexes={@ORM\Index(name="fk_estimate_of_repair_verification1_idx", columns={"verification_id"})})
 * @ORM\Entity
 */
class EstimateOfRepair
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
     * @var string|null
     *
     * @ORM\Column(name="current_editor", type="string", length=10, nullable=true)
     */
    private $currentEditor;

    /**
     * @var string|null
     *
     * @ORM\Column(name="remarks", type="text", length=16, nullable=true)
     */
    private $remarks;

    /**
     * @var \Survey
     *
     * @ORM\ManyToOne(targetEntity="Survey")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="verification_id", referencedColumnName="id")
     * })
     */
    private $verification;


}
