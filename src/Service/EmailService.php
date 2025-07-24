<?php
namespace App\Service;

use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;

class EmailService
{
    private MailerInterface $mailer;

    public function __construct(MailerInterface $mailer)
    {
        $this->mailer = $mailer;
    }

    public function sendResetPasswordEmail(string $toEmail, string $resetLink): void
    {
        $email = (new Email())
            ->from('no-reply@yourapp.com')
            ->to($toEmail)
            ->subject('Réinitialisation de votre mot de passe')
            ->text("Cliquez sur ce lien pour réinitialiser votre mot de passe : $resetLink")
            ->html("<p>Cliquez sur ce lien pour réinitialiser votre mot de passe :</p><p><a href=\"$resetLink\">$resetLink</a></p>");

        $this->mailer->send($email);
    }

    public function sendFirstLogin(string $toEmail, string $resetLink, string $plainPassword): void
    {
        $email = (new Email())
            ->from('no-reply@yourapp.com')
            ->to($toEmail)
            ->subject('Vos accès à la plateforme')
            ->text("
                Voici vos identifiants de connexion :
                Email : $toEmail
                Mot de passe : $plainPassword

                Cliquez sur ce lien pour définir un nouveau mot de passe :
                $resetLink
            ")
            ->html("
                <p>Voici vos identifiants de connexion :</p>
                <ul>
                    <li><strong>Email :</strong> $toEmail</li>
                    <li><strong>Mot de passe :</strong> $plainPassword</li>
                </ul>
                <p>Cliquez sur ce lien pour définir un nouveau mot de passe :</p>
                <p><a href=\"$resetLink\">$resetLink</a></p>
            ");

        $this->mailer->send($email);
    }

}
