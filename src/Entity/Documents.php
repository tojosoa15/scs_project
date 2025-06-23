<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Documents
 *
 * @ORM\Table(name="documents", indexes={@ORM\Index(name="fk_documents_survey_information1_idx", columns={"survey_information_id"})})
 * @ORM\Entity
 */
class Documents
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
     * @ORM\Column(name="attachements", type="string", length=255, nullable=true)
     */
    private $attachements;

    /**
     * @var \SurveyInformation
     *
     * @ORM\ManyToOne(targetEntity="SurveyInformation")
     * @ORM\JoinColumns({
     *   @ORM\JoinColumn(name="survey_information_id", referencedColumnName="id")
     * })
     */
    private $surveyInformation;


}
