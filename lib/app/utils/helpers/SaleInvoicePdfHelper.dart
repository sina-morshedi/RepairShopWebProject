import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../../features/dashboard/models/InventorySaleLogDTO.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io' as io show Platform;

import 'package:file_selector/file_selector.dart';

import 'package:flutter/services.dart';
import 'dart:io' as io;

class SaleInvoicePdfHelper {
  static Future<void> generateAndDownloadSaleInvoicePdf({
    required pw.Font customFont,
    required pw.MemoryImage logoImage,
    required InventorySaleLogDTO saleLog,
  }) async {
    final pdf = pw.Document();
    final double titleFontSize = 20;
    final double fontSize = 10;

    final now = saleLog.saleDate ?? DateTime.now();
    final formattedDate =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final invoiceNumber = "S-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${saleLog.customerName ?? 'Musteri'}";

    final total = saleLog.totalAmount ?? 0.0;
    final totalPaid = saleLog.paymentRecords?.fold<double>(
      0.0,
          (sum, p) => sum + (p.amountPaid),
    ) ??
        0.0;
    final remaining = saleLog.remainingAmount ?? (total - totalPaid);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(child: pw.Image(logoImage, width: 200, height: 200)),
          pw.SizedBox(height: 16),
          pw.Text("Parça Satış Faturası",
              style: pw.TextStyle(fontSize: titleFontSize, font: customFont)),

          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Fatura No: $invoiceNumber",
                  style: pw.TextStyle(fontSize: fontSize, font: customFont)),
              pw.Text("Tarih: $formattedDate",
                  style: pw.TextStyle(fontSize: fontSize, font: customFont)),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Text("Müşteri: ${saleLog.customerName ?? '-'}",
              style: pw.TextStyle(fontSize: fontSize, font: customFont)),

          pw.SizedBox(height: 24),

          pw.Text("Satılan Parçalar:",
              style: pw.TextStyle(fontSize: titleFontSize-4, font: customFont)),
          pw.Table.fromTextArray(
            headers: ['#', 'Parça Adı', 'Adet', 'Birim Fiyat', 'Toplam'],
            data: List.generate(saleLog.soldItems?.length ?? 0, (index) {
              final item = saleLog.soldItems![index];
              final unit = item.unitSalePrice ?? 0.0;
              final qty = item.quantitySold ?? 0;
              final total = unit * qty;
              return [
                (index + 1).toString(),
                item.partName ?? '',
                qty.toString(),
                "${unit.toStringAsFixed(2)} ₺",
                "${total.toStringAsFixed(2)} ₺",
              ];
            }),
            cellStyle: pw.TextStyle(fontSize: fontSize, font: customFont),
            headerStyle:
            pw.TextStyle(font: customFont, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Toplam: ${total.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(fontSize: titleFontSize-6, font: customFont)),
          ),

          if (saleLog.paymentRecords != null &&
              saleLog.paymentRecords!.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text("Ödeme Kayıtları:",
                style: pw.TextStyle(
                    fontSize: titleFontSize-4,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont)),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: saleLog.paymentRecords!.map((payment) {
                final date =
                    "${payment.paymentDate.year}/${payment.paymentDate.month.toString().padLeft(2, '0')}/${payment.paymentDate.day.toString().padLeft(2, '0')}";
                final amount = payment.amountPaid.toStringAsFixed(2);
                return pw.Text("• $date — $amount ₺",
                    style: pw.TextStyle(fontSize: fontSize, font: customFont));
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Ödenen Toplam: ${totalPaid.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(
                    fontSize: titleFontSize-8,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Kalan Tutar: ${remaining.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(
                    fontSize: titleFontSize-8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                    font: customFont),
              ),
            ),
            pw.SizedBox(height: 24),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey200,
              ),
              child: pw.Text(
                '''Not: 
                  FARUK KARABACAK
                  GARANTİ BANKASI
                  IBAN  : TR87 0006 2001 2010 0006 6536 55''',
                style: pw.TextStyle(fontSize: fontSize, font: customFont),
              ),
            ),
          ],
        ],
      ),
    );

    final bytes = await pdf.save();

    await _savePdf(bytes, "$invoiceNumber.pdf");
  }
  /// Private helper to save the PDF depending on platform
  static Future<void> _savePdf(Uint8List bytes, String filename) async {
    if (kIsWeb) {
      // Web: create Blob and auto-download
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else if (io.Platform.isWindows) {
      // Windows: ask user where to save
      final location = await getSaveLocation(
        acceptedTypeGroups: [
          XTypeGroup(label: 'pdf', extensions: ['pdf']),
        ],
        suggestedName: filename,
      );

      final path = location?.path;
      if (path != null) {
        final file = io.File(path);
        await file.writeAsBytes(bytes);
      }
    }
  }
}
