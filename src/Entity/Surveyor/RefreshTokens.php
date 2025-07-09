<?php

namespace App\Entity\Surveyor;

use App\Repository\RefreshTokensRepository;
use Doctrine\ORM\Mapping as ORM;
use Gesdinet\JWTRefreshTokenBundle\Model\AbstractRefreshToken;
/**
 * @ORM\Entity(repositoryClass="App\Repository\RefreshTokensRepository")
 * @ORM\Table(name="refresh_tokens")
 */
class RefreshTokens extends AbstractRefreshToken
{
    /**
     * @ORM\Id
     * @ORM\Column(type="string", length=128)
     */
    protected $refreshToken;

    /**
     * @ORM\Column(type="string", length=255)
     */
    protected $username;

    /**
     * @ORM\Column(type="datetime")
     */
    protected $valid;
}
