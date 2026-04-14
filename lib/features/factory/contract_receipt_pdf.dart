import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// إنشاء وعرض/طباعة PDF لإذن الاستلام (محلي — بيانات وهمية).
Future<void> openReceiptPdf({
  required String receiptNumber,
  required DateTime receiptAt,
  required String farmerName,
  required String productName,
  required double receivedTons,
}) async {
  final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
  final arabic = pw.Font.ttf(fontData);
  final fmt = DateFormat.yMMMd('ar').add_Hm();

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'حصاد — إذن استلام إلكتروني',
                style: pw.TextStyle(
                  font: arabic,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              _line(arabic, 'رقم الإذن', receiptNumber),
              _line(arabic, 'التاريخ والوقت', fmt.format(receiptAt)),
              _line(arabic, 'المزارع', farmerName),
              _line(arabic, 'المنتج', productName),
              _line(
                arabic,
                'الكمية المستلمة (طن)',
                receivedTons.toStringAsFixed(2),
              ),
              pw.Spacer(),
              pw.Text(
                'وثيقة صادرة آلياً — للمراجعة الداخلية',
                style: pw.TextStyle(
                  font: arabic,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    name: 'receipt_$receiptNumber.pdf',
    onLayout: (PdfPageFormat format) async => doc.save(),
  );
}

pw.Widget _line(pw.Font font, String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          '$label:',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey800),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );
}
