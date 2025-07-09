<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20250709205602 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE refresh_tokens (refresh_token VARCHAR(128) NOT NULL, username VARCHAR(255) NOT NULL, valid DATETIME NOT NULL, PRIMARY KEY(refresh_token)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('ALTER TABLE additional_labour_detail CHANGE estimate_of_repair_id estimate_of_repair_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE documents CHANGE survey_information_id survey_information_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE estimate_of_repair CHANGE verification_id verification_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE labour_detail CHANGE part_detail_id part_detail_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE part_detail CHANGE estimate_of_repair_id estimate_of_repair_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE picture_of_domage_car CHANGE survey_information_id survey_information_id INT DEFAULT NULL');
        $this->addSql('CREATE INDEX fk_survey_status1_idx ON survey (status_id)');
        $this->addSql('ALTER TABLE survey_information CHANGE verification_id verification_id INT DEFAULT NULL');
        $this->addSql('ALTER TABLE vehicle_information CHANGE verification_id verification_id INT DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('DROP TABLE refresh_tokens');
        $this->addSql('ALTER TABLE additional_labour_detail CHANGE estimate_of_repair_id estimate_of_repair_id INT NOT NULL');
        $this->addSql('ALTER TABLE picture_of_domage_car CHANGE survey_information_id survey_information_id INT NOT NULL');
        $this->addSql('ALTER TABLE vehicle_information CHANGE verification_id verification_id INT NOT NULL');
        $this->addSql('ALTER TABLE survey_information CHANGE verification_id verification_id INT NOT NULL');
        $this->addSql('ALTER TABLE documents CHANGE survey_information_id survey_information_id INT NOT NULL');
        $this->addSql('DROP INDEX fk_survey_status1_idx ON survey');
        $this->addSql('ALTER TABLE estimate_of_repair CHANGE verification_id verification_id INT NOT NULL');
        $this->addSql('ALTER TABLE part_detail CHANGE estimate_of_repair_id estimate_of_repair_id INT NOT NULL');
        $this->addSql('ALTER TABLE labour_detail CHANGE part_detail_id part_detail_id INT NOT NULL');
    }
}
