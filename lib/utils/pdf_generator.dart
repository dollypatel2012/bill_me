import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/organization.dart';
import '../models/biller.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class PdfGenerator {
  static Future<File> generateInvoice({
    required Organization organization,
    required Biller biller,
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    final pdf = pw.Document();

    // Use built‑in Helvetica fonts.
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
          _buildHeader(organization, invoice),
          _buildBillerInfo(biller),
          _buildItemsTable(items),
          _buildTotals(invoice),
          _buildSignature(organization),
          _buildDeclaration(),
        ],
      ),
    );

    // Sanitize invoice number for use as filename
    final safeInvoiceNo = invoice.invoiceNo.replaceAll(RegExp(r'[^\w\-]'), '_');
    final fileName = 'invoice_$safeInvoiceNo.pdf';

    // Get temporary directory
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/$fileName';

    print('Saving PDF to: $filePath'); // Debug output

    try {
      final bytes = await pdf.save();
      final file = File(filePath);
      // Ensure directory exists (it should, but just in case)
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      print('PDF saved successfully. Size: ${bytes.length} bytes');
      return file;
    } catch (e, stack) {
      print('Error saving PDF: $e');
      print(stack);
      throw Exception('Failed to save PDF: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Helper widgets (unchanged, but ensure no 'const' on non‑const objects)
  // -------------------------------------------------------------------------

  static pw.Widget _buildHeader(Organization org, Invoice inv) {
    return pw.Column(
      children: [
        pw.Text(
          org.name,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(org.addressLine1),
        if (org.addressLine2 != null) pw.Text(org.addressLine2!),
        pw.Text('GSTIN: ${org.gstin}  Phone: ${org.phone}'),
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

  static pw.Widget _buildSignature(Organization org) {
    if (org.signaturePath != null) {
      try {
        final imageFile = File(org.signaturePath!);
        if (imageFile.existsSync()) {
          final image = pw.MemoryImage(imageFile.readAsBytesSync());
          return pw.Container(
            height: 50,
            child: pw.Image(image),
          );
        }
      } catch (_) {}
    }
    return pw.SizedBox();
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