import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/product_model.dart';
import 'app_strings.dart';
import 'formatters.dart';

class PdfBuilder {
  static Future<Uint8List> build(
    List<ProductModel> products,
    AppStrings s,
  ) async {
    final rtl = s.isDari;
    final dari = await _font('Vazirmatn-Regular');
    final dariBold = await _font('Vazirmatn-Bold');
    final english = await _font('Inter-Regular');
    final englishBold = await _font('Inter-Bold');
    final theme = pw.ThemeData.withFont(
      base: rtl ? dari : english,
      bold: rtl ? dariBold : englishBold,
      fontFallback: rtl ? [english, englishBold] : [dari, dariBold],
    );

    final doc = pw.Document();

    final totalQty = products.fold<int>(0, (sum, p) => sum + p.quantity);
    final totalPurchasedQty =
        products.fold<int>(0, (sum, p) => sum + p.initialQuantity);
    final totalPrice =
        products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              s.warehouseProductList,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              s.generatedAt(
                Formatters.dateTime(DateTime.now().toIso8601String()),
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Divider(thickness: 1, color: PdfColors.green800),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.green700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
            },
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.green50),
            headers: [
              '#',
              s.productName,
              s.qty,
              s.purchasedQty,
              s.unit,
              s.category,
              s.department,
              s.totalPrice,
            ],
            data: products.asMap().entries.map((e) {
              final i = e.key + 1;
              final p = e.value;
              return [
                '$i',
                p.name,
                '${p.quantity}',
                '${p.initialQuantity}',
                p.unitName ?? '-',
                p.categoryName ?? '-',
                p.departmentName ?? '-',
                Formatters.currency(p.price * p.quantity),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColors.green700,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  s.pdfTotals(products.length),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
                pw.Row(
                  children: [
                    _totalChip(s.totalQty, '$totalQty'),
                    pw.SizedBox(width: 16),
                    _totalChip(s.purchasedQty, '$totalPurchasedQty'),
                    pw.SizedBox(width: 16),
                    _totalChip(s.totalPrice, Formatters.currency(totalPrice)),
                  ],
                ),
              ],
            ),
          ),
        ],
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              s.anbarInventory,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              s.pageOf(ctx.pageNumber, ctx.pagesCount),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static Future<pw.Font> _font(String name) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$name.ttf'));

  static pw.Widget _totalChip(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.green100),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }
}

class PdfPrinter {
  static Future<void> print(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
