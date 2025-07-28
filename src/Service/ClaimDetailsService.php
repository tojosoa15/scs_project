<?php

namespace App\Service;

use Doctrine\DBAL\Connection;

class ClaimDetailsService
{
    private Connection $connection;

    public function __construct(Connection $claimDetailsConnection)
    {
        $this->connection = $claimDetailsConnection;
    }

    public function callGetClaimDetails(array $params): array
    {
        // $sql = "CALL GetClaimDetails(?, ?)";
        
        // $stmt = $this->connection->prepare($sql);
        // $stmt->bindValue(1, $params['p_claim_number']);
        // $stmt->bindValue(2, $params['p_email']);
        
        // return $stmt->executeQuery()->fetchAssociative();
         $pdo = $this->connection->getNativeConnection(); // Retourne un \PDO natif
    
        $stmt = $pdo->prepare("CALL GetClaimDetails(:claim_number, :email)");
        $stmt->bindValue(':claim_number', $params['p_claim_number']);
        $stmt->bindValue(':email', $params['p_email']);
        $stmt->execute();
    
        $summaries = [];
    
        // 1. Survey Information
        $vehicle_surveis = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        foreach ($vehicle_surveis as $vehicle_survey) {
            $summaries['vehicle_information']  = [
                        'make'                      => $vehicle_survey['make'],
                        'model'                     => $vehicle_survey['model'],
                        'cc'                        => $vehicle_survey['cc'],
                        'fuel_type'                 => $vehicle_survey['fuel_type'],
                        'transmission'              => $vehicle_survey['transmission'],
                        'engime_no'                 => $vehicle_survey['engime_no'],
                        'chasisi_no'                => $vehicle_survey['chasisi_no'],
                        'vehicle_no'                => $vehicle_survey['vehicle_no'],
                        'color'                     => $vehicle_survey['color'],
                        'odometer_reading'          => $vehicle_survey['odometer_reading'],
                        'is_the_vehicle_total_loss' => $vehicle_survey['is_the_vehicle_total_loss'],
                        'condition_of_vehicle'      => $vehicle_survey['condition_of_vehicle'],    
                        'place_of_survey'           => $vehicle_survey['place_of_survey'],
                        'point_of_impact'           => $vehicle_survey['point_of_impact']
            ];
            $summaries['survey_information'] = [
                            'garage'                => $vehicle_survey['garage'],
                            'garage_address'        => $vehicle_survey['garage_address'],
                            'garage_contact_number' => $vehicle_survey['garage_contact_number'],
                            'eor_value'             => $vehicle_survey['eor_value'],
                            'invoice_number'        => $vehicle_survey['invoice_number'],
                            'survey_type'           => $vehicle_survey['survey_type'],
                            'date_of_survey'        => $vehicle_survey['date_of_survey']
            ];
        }
    
        // 2. Vehicle Information
        // if ($stmt->nextRowset()) {
        //     $summaries['vehicle_information'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        // }
    
        // 3. Part Summary
        if ($stmt->nextRowset()) {
            $summaries['part_details'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 4. Labour Summary
        if ($stmt->nextRowset()) {
            $summaries['labour_details'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 5. Grand Totals
        if ($stmt->nextRowset()) {
            $summaries['grand_totals'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        return $summaries;
    }

    public function callSpVerificationProcessSurveyor(array $params): array
    {
        $sql = "CALL SpVerificationProcessSurveyor(?, ?, ?, ?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_surveyor_id']);
        $stmt->bindValue(3, $params['p_status']);
        $stmt->bindValue(4, $params['p_current_step']);
        $stmt->bindValue(5, $params['p_json_data']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    public function callGetSummary(array $params): array
    {
        $sql = "CALL GetSummary(?, ?)";
        
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(1, $params['p_claim_number']);
        $stmt->bindValue(2, $params['p_email']);
        
        return $stmt->executeQuery()->fetchAllAssociative();
    }

    public function callGetSummary_backup(array $params): array
    {
        $pdo = $this->connection->getNativeConnection(); // Retourne un \PDO natif
    
        $stmt = $pdo->prepare("CALL GetSummary(:claim_number, :email)");
        $stmt->bindValue(':claim_number', $params['p_claim_number']);
        $stmt->bindValue(':email', $params['p_email']);
        $stmt->execute();
    
        $summaries = [];
    
        // 1. Survey Information
        $summaries['survey_information'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
    
        // 2. Vehicle Information
        if ($stmt->nextRowset()) {
            $summaries['vehicle_information'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 3. Part Summary
        if ($stmt->nextRowset()) {
            $summaries['part_summary'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 4. Labour Summary
        if ($stmt->nextRowset()) {
            $summaries['labour_summary'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        // 5. Grand Totals
        if ($stmt->nextRowset()) {
            $summaries['grand_totals'] = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        }
    
        return $summaries;
    } 
}