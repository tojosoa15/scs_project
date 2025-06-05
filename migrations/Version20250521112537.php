<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20250521112537 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE draft_vehicle_informations DROP CONSTRAINT DF_23F38554_4C3CE4ED
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE draft_vehicle_informations ALTER COLUMN is_the_vehicle_total_loss BIT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE estimate_of_repairs ALTER COLUMN verifications_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE estimate_of_repairs ALTER COLUMN claims_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE labour_details ALTER COLUMN part_details_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE labour_details ALTER COLUMN vats_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_delivery_details ALTER COLUMN users_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_delivery_details ALTER COLUMN repair_parts_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_details ALTER COLUMN estimate_of_repairs_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_details ALTER COLUMN vats_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE payements ALTER COLUMN status_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE pictures_of_damaged_cars ALTER COLUMN survey_informations_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs ALTER COLUMN claims_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs ALTER COLUMN garage_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs_draft ALTER COLUMN claims_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs_draft ALTER COLUMN garage_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN rapairs_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN part_details_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN users_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE survey_informations ALTER COLUMN verifications_id INT
        SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE user_roles DROP COLUMN assigned_at
        // SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE user_roles DROP COLUMN is_active
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN estimate_of_repairs_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN condition_of_vechicle_id INT
        SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE vehicle_informations DROP CONSTRAINT DF_D67E8BFD_4C3CE4ED
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN is_the_vehicle_total_loss BIT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications ALTER COLUMN claims_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications ALTER COLUMN surveyor_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications_draft ALTER COLUMN claims_id INT
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications_draft ALTER COLUMN surveyor_id INT
        SQL);
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_accessadmin
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_backupoperator
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_datareader
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_datawriter
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_ddladmin
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_denydatareader
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_denydatawriter
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_owner
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA db_securityadmin
        SQL);
        $this->addSql(<<<'SQL'
            CREATE SCHEMA dbo
        SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE user_roles ADD assigned_at DATETIME2(6) CONSTRAINT DF_54FCD59F_343E8069 DEFAULT CURRENT_TIMESTAMP
        // SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE user_roles ADD is_active BIT CONSTRAINT DF_54FCD59F_1B5771DD DEFAULT 1
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE estimate_of_repairs ALTER COLUMN verifications_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE estimate_of_repairs ALTER COLUMN claims_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE payements ALTER COLUMN status_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN estimate_of_repairs_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN condition_of_vechicle_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE vehicle_informations ALTER COLUMN is_the_vehicle_total_loss BIT NOT NULL
        SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE vehicle_informations ADD CONSTRAINT DF_D67E8BFD_4C3CE4ED DEFAULT 0 FOR is_the_vehicle_total_loss
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE survey_informations ALTER COLUMN verifications_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE pictures_of_damaged_cars ALTER COLUMN survey_informations_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_details ALTER COLUMN estimate_of_repairs_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_details ALTER COLUMN vats_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE labour_details ALTER COLUMN part_details_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE labour_details ALTER COLUMN vats_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications ALTER COLUMN claims_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications ALTER COLUMN surveyor_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications_draft ALTER COLUMN claims_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE verifications_draft ALTER COLUMN surveyor_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE draft_vehicle_informations ALTER COLUMN is_the_vehicle_total_loss BIT NOT NULL
        SQL);
        // $this->addSql(<<<'SQL'
        //     ALTER TABLE draft_vehicle_informations ADD CONSTRAINT DF_23F38554_4C3CE4ED DEFAULT 0 FOR is_the_vehicle_total_loss
        // SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs ALTER COLUMN claims_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs ALTER COLUMN garage_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN rapairs_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN part_details_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE repair_parts ALTER COLUMN users_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_delivery_details ALTER COLUMN users_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE part_delivery_details ALTER COLUMN repair_parts_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs_draft ALTER COLUMN claims_id INT NOT NULL
        SQL);
        $this->addSql(<<<'SQL'
            ALTER TABLE rapairs_draft ALTER COLUMN garage_id INT NOT NULL
        SQL);
    }
}
