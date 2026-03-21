import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/biller.dart';
import '../models/invoice_item.dart';
import '../providers/invoice_provider.dart';
import '../services/share_service.dart';
import '../utils/pdf_generator.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;
  final Invoice invoice;
  final List<InvoiceItem> items;
  final Biller biller;  // <-- Add this

  PdfPreviewScreen({
    required this.pdfFile,
    required this.invoice,
    required this.items,
    required this.biller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Invoice'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              // Use share service
              await ShareService.sharePdf(pdfFile);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Save the invoice to database
              await Provider.of<InvoiceProvider>(context, listen: false)
                  .saveCompleteInvoice(invoice, items);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice saved')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytesSync(),
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}