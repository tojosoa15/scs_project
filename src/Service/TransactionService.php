<?php

namespace App\Service;

use App\Entity\Scs\Transaction;
use Doctrine\ORM\EntityManagerInterface;
use Dompdf\Dompdf;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Twig\Environment;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Color;
use PhpOffice\PhpSpreadsheet\Style\Border;
use Symfony\Component\HttpFoundation\Response;

/**
 * Class BookingFormService
 * @package App\Service
 */
class TransactionService
{
    /**
	 * @param EntityManagerInterface $entityManager
     * @param Environment $twig
	 */
    public function __construct(
        private EntityManagerInterface $entityManager,
        private Environment $twig,
    )
    {
    }

    /**
     * Génération détail PDF
     * 
     * @param Transaction $transaction
     * @return void
     */
    public function generatePdf($transactions)
    {
        $pdfOptions = new \Dompdf\Options();
        $pdfOptions->set('defaultFont', 'Arial')->setIsRemoteEnabled(true);
        $pdfOptions->set("isPhpEnabled", true);
        $pdf = new Dompdf($pdfOptions);
        
        $template = $this->twig->render("transaction/pdf.html.twig", [
            'transaction' => $transactions
        ]);

        $pdf->loadHtml($template);
        $pdf->setPaper('A4', 'portrait');
        $pdf->render();

        $date           = (new \DateTime())->format('d_m_Y_H_i_s');
        $filename       = "transaction" . $date . ".pdf";
        // $pdf->stream($filename, ["Attachment" => true]);

        $pdfContent = $pdf->output();

        return new Response($pdfContent, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ]);
    }

    
    /**
     * Génération détail Excel
     * 
     * @param Transaction $transaction
     * @return void
     */
    public function generateExcel(array $transactions): StreamedResponse
    {
        
        $items = $transactions['items'] ?? $transactions;
        $totalTransactions = $transactions['total_transaction'] ?? count($items);

        
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Transaction History');

        
        $sheet->mergeCells('A1:I1');
        $sheet->setCellValue('A1', 'Transaction History');
        $sheet->getStyle('A1')->getFont()->setBold(true)->setSize(14);
        $sheet->getStyle('A1')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

    
        $headers = [
            'Date',
            'Fund Name',
            'Sub account Reference',
            'Transaction Type',
            'CN Number',
            'No of Units',
            'Net Amount (MUR)',
            'Currency',
            'Net Amount Invested/ Redeemed'
        ];
        $sheet->fromArray($headers, null, 'A3');

        // Style de l'en-tête
        $sheet->getStyle('A3:I3')->applyFromArray([
            'font' => ['bold' => true],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'fill' => [
                'fillType' => Fill::FILL_SOLID,
                'color' => ['argb' => 'FFF2F2F2']
            ],
            'borders' => [
                'allBorders' => ['borderStyle' => Border::BORDER_THIN]
            ]
        ]);

        
        $row = 4;
        foreach ($items as $t) {
            // Formatage de la date (si c’est un objet ou une chaîne brute)
            $date = '';
            if (!empty($t['date'])) {
                try {
                    $dateObj = new \DateTime($t['date']);
                    $date = $dateObj->format('Y-m-d');
                } catch (\Exception $e) {
                    $date = $t['date'];
                }
            }

            $sheet->fromArray([
                $date,
                $t['fund_name'] ?? '',
                $t['sub_account_reference'] ?? '',
                $t['transaction_type'] ?? '',
                $t['cn_number'] ?? '',
                isset($t['no_of_units']) ? number_format((float)$t['no_of_units'], 0, '.', ',') : '',
                isset($t['net_amount_mur']) ? number_format((float)$t['net_amount_mur'], 2, '.', ',') : '',
                $t['currency'] ?? '',
                isset($t['net_amount_inv_redeemed']) ? number_format((float)$t['net_amount_inv_redeemed'], 2, '.', ',') : '',
            ], null, "A{$row}");

            // Couleur selon le type de transaction
            $type = strtolower($t['transaction_type'] ?? '');
            $color = null;

            if (str_contains($type, 'additional') || str_contains($type, 'gift')) {
                $color = 'FF00B050'; // vert
            } elseif (str_contains($type, 'switch out')) {
                $color = 'FFFF0000'; // rouge
            } elseif (str_contains($type, 'switch in')) {
                $color = 'FF0070C0'; // bleu
            }

            if ($color) {
                $sheet->getStyle("D{$row}")->getFont()->getColor()->setARGB($color);
                $sheet->getStyle("D{$row}")->getFont()->setBold(true);
            }

            // Bordures de la ligne
            $sheet->getStyle("A{$row}:I{$row}")->applyFromArray([
                'borders' => [
                    'allBorders' => ['borderStyle' => Border::BORDER_THIN]
                ]
            ]);

            $row++;
        }


        $sheet->setCellValue("H{$row}", 'Total Transactions:');
        $sheet->setCellValue("I{$row}", $totalTransactions);
        $sheet->getStyle("H{$row}:I{$row}")->getFont()->setBold(true);
        $sheet->getStyle("H{$row}:I{$row}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);

        
        foreach (range('A', 'I') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }


        $response = new StreamedResponse(function () use ($spreadsheet) {
            $writer = new Xlsx($spreadsheet);
            $writer->save('php://output');
        });

        $response->headers->set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        $response->headers->set('Content-Disposition', 'attachment; filename="transaction_history.xlsx"');
        $response->headers->set('Cache-Control', 'max-age=0');

        return $response;
        }


    /**
     * Génération détail CSV
     * 
     * @param Transaction $transactions
     * @return void
     */
        public function generateCsv(array $transactions): StreamedResponse
            {
    
                $items = $transactions['items'] ?? $transactions;
                $totalTransactions = $transactions['total_transaction'] ?? count($items);

            
                $headers = [
                    'Date',
                    'Fund Name',
                    'Sub account Reference',
                    'Transaction Type',
                    'CN Number',
                    'No of Units',
                    'Net Amount (MUR)',
                    'Currency',
                    'Net Amount Invested/ Redeemed'
                ];

                
                $response = new StreamedResponse(function () use ($items, $headers, $totalTransactions) {
                    $handle = fopen('php://output', 'w');

                    // Définir l'encodage UTF-8 avec BOM pour Excel
                    fprintf($handle, chr(0xEF).chr(0xBB).chr(0xBF));

                    // Écrire les en-têtes
                    fputcsv($handle, $headers);

                    // Écrire les données
                    foreach ($items as $t) {
                        $date = '';
                        if (!empty($t['date'])) {
                            try {
                                $dateObj = new \DateTime($t['date']);
                                $date = $dateObj->format('Y-m-d');
                            } catch (\Exception $e) {
                                $date = $t['date'];
                            }
                        }

                        fputcsv($handle, [
                            $date,
                            $t['fund_name'] ?? '',
                            $t['sub_account_reference'] ?? '',
                            $t['transaction_type'] ?? '',
                            $t['cn_number'] ?? '',
                            isset($t['no_of_units']) ? number_format((float)$t['no_of_units'], 0, '.', ',') : '',
                            isset($t['net_amount_mur']) ? number_format((float)$t['net_amount_mur'], 2, '.', ',') : '',
                            $t['currency'] ?? '',
                            isset($t['net_amount_inv_redeemed']) ? number_format((float)$t['net_amount_inv_redeemed'], 2, '.', ',') : '',
                        ]);
                    }

                    // Ligne du total
                    fputcsv($handle, array_fill(0, 7, ''));
                    fputcsv($handle, ['', '', '', '', '', '', 'Total Transactions:', $totalTransactions]);

                    fclose($handle);
                });

            
                $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
                $response->headers->set('Content-Disposition', 'attachment; filename="transaction_history.csv"');
                $response->headers->set('Cache-Control', 'max-age=0');

                return $response;
            }

}

