import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../models/biller.dart';
import '../models/invoice_item.dart';

class PdfGenerator {
  static Future<File> generateInvoice({
    required Invoice invoice,
    required Biller biller,
    required List<InvoiceItem> items,
  }) async {
    final pdf = pw.Document();

    // Use built‑in Helvetica fonts (no external file needed)
    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    final theme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) => [
          _buildHeader(invoice),
          _buildBillerInfo(biller),
          _buildItemsTable(items),
          _buildTotals(invoice),
          _buildSignature(invoice),
          _buildDeclaration(),
        ],
      ),
    );

    final safeInvoiceNo = invoice.invoiceNo.replaceAll(RegExp(r'[^\w\-]'), '_');
    final fileName = 'invoice_$safeInvoiceNo.pdf';
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(Invoice inv) {
    return pw.Column(
      children: [
        pw.Text(
          inv.orgName ?? '',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(inv.orgAddressLine1 ?? ''),
        if (inv.orgAddressLine2 != null && inv.orgAddressLine2!.isNotEmpty)
          pw.Text(inv.orgAddressLine2!),
        pw.Text('GSTIN: ${inv.orgGstin ?? ''}  Phone: ${inv.orgPhone ?? ''}'),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Invoice No: ${inv.invoiceNo}'),
            pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(inv.invoiceDate)}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBillerInfo(Biller b) {
    return pw.Container(
      margin: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Billed To: ${b.name}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Address: ${b.address}'),
          pw.Text('GSTIN: ${b.gstin ?? ''}  UID: ${b.uid ?? ''}'),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    const tableHeaders = ['Item', 'Qty', 'Rate', 'Disc%', 'Taxable', 'Tax', 'Amount'];
    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: items.map((i) => [
        i.itemName,
        i.quantity.toString(),
        i.rate.toStringAsFixed(2),
        i.discountPercent.toString(),
        i.taxableAmt.toStringAsFixed(2),
        i.totalTax.toStringAsFixed(2),
        i.amount.toStringAsFixed(2),
      ]).toList(),
    );
  }

  static pw.Widget _buildTotals(Invoice inv) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Total Discount: ${inv.totalDiscount.toStringAsFixed(2)}'),
          pw.Text('Total Tax: ${inv.totalTax.toStringAsFixed(2)}'),
          pw.Text('Net Payable: ${inv.netPayable.toStringAsFixed(2)}'),
          pw.Text(
            inv.amountInWords,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignature(Invoice inv) {
    // Note: signature is not stored in invoice; we would need to fetch it from organization?
    // For simplicity, we skip or use a placeholder. You could store the signature path in invoice
    // or pass it separately. We'll just use a placeholder.
    return pw.SizedBox();
    // Alternatively, if you store signature path in invoice, you could use it.
  }

  static pw.Widget _buildDeclaration() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Statutory Declaration under FSS Act 2006: I/We hereby certify that '
          'food/foods mentioned in this invoice is/are warranted to be of the '
          'nature and quality which it/they purports/purported to be.',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Authorised Signatory'),
      ],
    );
  }
}