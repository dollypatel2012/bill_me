import 'dart:io';
import 'package:provider/provider.dart'; 
import '../providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/share_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;
  final Invoice invoice;
  final List<InvoiceItem> items;

  PdfPreviewScreen({required this.pdfFile, required this.invoice, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Invoice'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => ShareService.sharePdf(pdfFile),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Save invoice to database
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