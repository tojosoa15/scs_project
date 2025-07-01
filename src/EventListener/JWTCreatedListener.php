<?php

namespace App\EventListener;

use Lexik\Bundle\JWTAuthenticationBundle\Event\JWTCreatedEvent;
use Symfony\Component\Security\Core\User\UserInterface;

class JWTCreatedListener
{
    public function onJWTCreated(JWTCreatedEvent $event): void
    {
        /** @var \App\Entity\ClaimUser\AccountInformations $user */
        $user = $event->getUser();

        if (!$user instanceof UserInterface) {
            return;
        }

        $payload = $event->getData();

        // Ajout d'infos personnalisées
        $payload['id']              = $user->getId();
        $payload['roles']           = $user->getRoles(); // Retourne les rôles réels
        $payload['business_name']   = $user->getBusinessName();

        $event->setData($payload);
    }
}
