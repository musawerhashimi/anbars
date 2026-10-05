import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/product_model.dart';
import '../../models/sold_product_model.dart';
import 'app_strings.dart';
import 'formatters.dart';

class PdfBuilder {
  static Future<Uint8List> build(
    List<ProductModel> products,
    AppStrings s,
  ) async {
    final rtl = s.isDari;
    final theme = await _theme(rtl);

    final doc = pw.Document();

    final totalQty = products.fold<int>(0, (sum, p) => sum + p.quantity);
    final totalPurchasedQty = products.fold<int>(
      0,
      (sum, p) => sum + p.initialQuantity,
    );
    final totalPrice = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.quantity),
    );

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
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
            },
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
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
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  /// Sold products over a period, one row per product, with grand totals.
  static Future<Uint8List> buildSalesReport(
    List<SoldProductModel> items,
    AppStrings s, {
    required String periodLabel,
    required int saleCount,
  }) async {
    final rtl = s.isDari;
    final theme = await _theme(rtl);
    final doc = pw.Document();

    final totalQty = items.fold<int>(0, (sum, x) => sum + x.quantity);
    final grandTotal = items.fold<double>(0, (sum, x) => sum + x.total);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  s.soldProductsReport,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Text(
                    s.period(periodLabel),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ],
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
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
            },
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
            headers: [
              '#',
              s.productName,
              s.unit,
              s.transactions,
              s.qtySold,
              s.unitPrice,
              s.totalPrice,
            ],
            data: [
              for (var i = 0; i < items.length; i++)
                [
                  '${i + 1}',
                  items[i].name,
                  items[i].unitName ?? '-',
                  '${items[i].saleCount}',
                  '${items[i].quantity}',
                  Formatters.currency(items[i].averagePrice),
                  Formatters.currency(items[i].total),
                ],
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.green700, PdfColors.blue700],
              ),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  s.pdfTotals(items.length),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
                pw.Row(
                  children: [
                    _totalChip(s.transactions, '$saleCount'),
                    pw.SizedBox(width: 18),
                    _totalChip(s.qtySold, '$totalQty'),
                    pw.SizedBox(width: 18),
                    _totalChip(s.grandTotal, Formatters.currency(grandTotal)),
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

  static Future<pw.ThemeData> _theme(bool rtl) async {
    final dari = await _font('Vazirmatn-Regular');
    final dariBold = await _font('Vazirmatn-Bold');
    final english = await _font('Inter-Regular');
    final englishBold = await _font('Inter-Bold');
    return pw.ThemeData.withFont(
      base: rtl ? dari : english,
      bold: rtl ? dariBold : englishBold,
      fontFallback: rtl ? [english, englishBold] : [dari, dariBold],
    );
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
