import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import 'bill_generation_screen.dart'; // for editing

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Invoice History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by customer name...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          invoiceProvider.clearSearch();
                        },
                      ),
                    ),
                    onChanged: (value) => invoiceProvider.searchByCustomer(value),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: _selectDateRange,
                ),
              ],
            ),
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('From: ${DateFormat.yMd().format(_startDate!)} To: ${DateFormat.yMd().format(_endDate!)}'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: invoiceProvider.filteredInvoices.length,
              itemBuilder: (ctx, i) {
                final inv = invoiceProvider.filteredInvoices[i];
                return Card(
                  child: ListTile(
                    title: Text('Invoice #${inv.invoiceNo}'),
                    subtitle: Text('${inv.customerName} - ${DateFormat.yMd().format(inv.invoiceDate)}'),
                    trailing: Text('₹${inv.netPayable.toStringAsFixed(2)}'),
                    onTap: () => _editInvoice(context, inv),
                    onLongPress: () => _deleteInvoice(context, inv),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      Provider.of<InvoiceProvider>(context, listen: false)
          .filterByDateRange(picked.start, picked.end);
    }
  }

  void _editInvoice(BuildContext context, Invoice inv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillGenerationScreen(existingInvoice: inv),
      ),
    );
  }

  void _deleteInvoice(BuildContext context, Invoice inv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Invoice'),
        content: Text('Delete invoice #${inv.invoiceNo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      Provider.of<InvoiceProvider>(context, listen: false).deleteInvoice(inv.id!);
    }
  }
}