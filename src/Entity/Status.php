<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Status
 *
 * @ORM\Table(name="status", uniqueConstraints={@ORM\UniqueConstraint(name="status_code_UNIQUE", columns={"status_code"}), @ORM\UniqueConstraint(name="status_name_UNIQUE", columns={"status_name"})})
 * @ORM\Entity
 */
class Status
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
     * @ORM\Column(name="status_code", type="string", length=45, nullable=false)
     */
    private $statusCode;

    /**
     * @var string
     *
     * @ORM\Column(name="status_name", type="string", length=45, nullable=false)
     */
    private $statusName;

    /**
     * @var string|null
     *
     * @ORM\Column(name="description", type="text", length=16, nullable=true)
     */
    private $description;

    /**
     * @var \DateTime|null
     *
     * @ORM\Column(name="update_at", type="datetime", nullable=true, options={"default"="CURRENT_TIMESTAMP"})
     */
    private $updateAt = 'CURRENT_TIMESTAMP';


}
