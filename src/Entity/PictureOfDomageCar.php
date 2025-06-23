<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * PictureOfDomageCar
 *
 * @ORM\Table(name="picture_of_domage_car", indexes={@ORM\Index(name="fk_picture_of_domage_car_survey_information1_idx", columns={"survey_information_id"})})
 * @ORM\Entity
 */
class PictureOfDomageCar
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
     * @ORM\Column(name="path", type="string", length=255, nullable=false)
     */
    private $path;

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
