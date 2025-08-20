<?php
namespace App\Service;

use Lcobucci\JWT\Configuration;

class MercureTokenGenerator
{
    private $mercureSecret;

    public function __construct(string $mercureSecret)
    {
        $this->mercureSecret = $mercureSecret;
    }

    public function generateToken(array $subscribe = [], array $publish = []): string
    {
        $config = Configuration::forSymmetricSigner(
            new \Lcobucci\JWT\Signer\Hmac\Sha256(),
            \Lcobucci\JWT\Signer\Key\InMemory::plainText($this->mercureSecret)
        );

        $now = new \DateTimeImmutable();
        $token = $config->builder()
            ->issuedAt($now)
            ->expiresAt($now->modify('+1 hour'))
            ->withClaim('mercure', [
                'subscribe' => $subscribe,
                'publish'   => $publish,
            ])
            ->getToken($config->signer(), $config->signingKey());

        return $token->toString();
    }
}