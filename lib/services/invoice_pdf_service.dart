import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/booking_request.dart';

class InvoicePdfService {
  /// Generate the PDF document bytes
  static Future<Uint8List> generateInvoicePdf(BookingRequest booking) async {
    final pdf = pw.Document();

    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ApnaExpert',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Doorstep Services & Repairs',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'TAX INVOICE / RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Invoice #: INV-${booking.id}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: $dateFormatted',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 12),

              // Billed To & Service Specialist
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'CUSTOMER DETAILS',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            booking.customerName.isNotEmpty ? booking.customerName : 'Customer',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          ),
                          if (booking.customerPhone.isNotEmpty)
                            pw.Text('Phone: ${booking.customerPhone}', style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Address: ${booking.address}',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                          ),
                          if (booking.landmark.isNotEmpty)
                            pw.Text('Landmark: ${booking.landmark}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SERVICE SPECIALIST',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            booking.selectedWorkerName ?? 'Assigned Professional',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          ),
                          if (booking.selectedWorkerPhone != null)
                            pw.Text('Phone: ${booking.selectedWorkerPhone}', style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Category: ${booking.categoryTitle}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                          ),
                          pw.Text(
                            'Scheduled Slot: ${booking.scheduledTime}',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Service Details Table
              pw.Text(
                'SERVICE & BILLING BREAKDOWN',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item / Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount (INR)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Doorstep Repair & Service',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                            ),
                            if (booking.problemDescription.isNotEmpty)
                              pw.Text(
                                booking.problemDescription,
                                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                              ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(booking.categoryTitle, style: const pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Rs. ${booking.estimatedCost.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Safety & Convenience Platform Fee', style: const pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Platform', style: const pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('FREE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                      ),
                    ],
                  ),
                  if (booking.discountAmount > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Coupon Discount applied', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Promo', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '- Rs. ${booking.discountAmount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Total Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Rs. ${booking.estimatedCost.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                        if (booking.discountAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Discount:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                              pw.Text('- Rs. ${booking.discountAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                            ],
                          ),
                        ],
                        pw.Divider(color: PdfColors.grey300),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Paid:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                            pw.Text(
                              'Rs. ${booking.finalCost.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // Payment Info Box
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Mode: ${booking.paymentMethod}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    pw.Text('Status: ${booking.status.label.toUpperCase()}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer Note
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'ApnaExpert Technologies Pvt Ltd • 24x7 Support: support@apnaexpert.in | 1800 200 4567',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated tax invoice and does not require a physical signature.',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Download or Print PDF on Web and Mobile
  static Future<void> downloadOrPrintInvoice(BuildContext context, BookingRequest booking) async {
    try {
      final pdfBytes = await generateInvoicePdf(booking);
      final fileName = 'Invoice_${booking.id}.pdf';

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice $fileName ready for download / share!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error downloading invoice PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Direct Layout / Print Preview
  static Future<void> printInvoice(BookingRequest booking) async {
    final pdfBytes = await generateInvoicePdf(booking);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${booking.id}.pdf',
    );
  }
}
