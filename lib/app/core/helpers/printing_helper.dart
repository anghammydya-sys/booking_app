import 'package:flutter/services.dart'; // <-- [مهم] للوصول إلى assets
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintingHelper {
  // لاحظ أننا لم نعد بحاجة لتمرير BuildContext
  static Future<void> printInvoice(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // --- [الحل النهائي والمؤكد] ---
    // 1. تحميل بيانات الخط من ملفات assets
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pw.Widget buildRow(String title, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(value, textDirection: pw.TextDirection.rtl),
            pw.Text(title, textDirection: pw.TextDirection.rtl),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        // 2. استخدام الخط الذي تم تحميله
        theme: pw.ThemeData.withFont(base: ttf),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text('فاتورة حجز', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 20),
                pw.Text('رقم الفاتورة: ${data['bookingNumber']}'),
                pw.Text('تاريخ الإنشاء: ${DateFormat.yMMMd('ar').format(DateTime.now())}'),
                pw.Divider(height: 20),
                buildRow('اسم العميل:', data['customerName']),
                buildRow('رقم الجوال:', data['customerPhone']),
                buildRow('تاريخ الحفلة:', DateFormat.yMMMd('ar').format(data['eventDate'])),
                buildRow('نوع الحفلة:', data['eventType']),
                pw.Divider(height: 20),
                ...(data['services'] as List<Map<String, String>>).map((service) {
                  return buildRow('${service['title']}:', '${service['amount']} ريال');
                }).toList(),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                buildRow('المبلغ الإجمالي:', '${data['totalAmount']} ريال'),
                pw.SizedBox(height: 40),
                pw.Center(child: pw.Text('توقيع العميل: ....................')),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text('توقيع المسؤول: ....................')),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
  // في PrintingHelper

// ... (بعد دالة printInvoice)

// --- [جديد] دالة لطباعة سند قبض ---
static Future<void> printPaymentReceipt(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  // تحميل الخط العربي
  final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  pw.Widget buildRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(title),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(base: ttf),
      pageFormat: PdfPageFormat.a5.landscape, // استخدام حجم أصغر للسند
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text('سند قبض', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 25),
                
                buildRow('رقم السند:', data['receiptNumber'].toString()),
                buildRow('التاريخ:', DateFormat('yyyy/MM/dd', 'ar').format(data['paymentDate'])),
                pw.Divider(height: 25),

                pw.Text('استلمنا من السيد/السيدة: ${data['customerName']}'),
                pw.SizedBox(height: 15),
                pw.Text('مبلغًا وقدره: ${data['amount']} ريال سعودي'),
                pw.SizedBox(height: 15),
                pw.Text('وذلك عن دفعة من حساب: ${data['bookingDescription']}'),
                pw.SizedBox(height: 15),
                pw.Text('طريقة الدفع: ${data['paymentMethod']}'),
                pw.SizedBox(height: 30),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('المستلم'),
                        pw.SizedBox(height: 20),
                        pw.Text('....................'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}

}
