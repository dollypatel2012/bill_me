import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/biller.dart';
import '../models/item.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../providers/biller_provider.dart';
import '../providers/item_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/organization_provider.dart';
import '../utils/pdf_generator.dart';
import '../utils/invoice_number_generator.dart';
import 'pdf_preview_screen.dart';
import 'widgets/item_form.dart';

class BillGenerationScreen extends StatefulWidget {
  final Invoice? existingInvoice;
  BillGenerationScreen({this.existingInvoice});

  @override
  _BillGenerationScreenState createState() => _BillGenerationScreenState();
}

class _BillGenerationScreenState extends State<BillGenerationScreen> {
  Biller? _selectedBiller;
  List<InvoiceItem> _lineItems = [];
  final _paymentModes = ['Credit', 'Cash', 'Online'];
  String _paymentMode = 'Credit';
  DateTime _invoiceDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now();
  String _docNo = '';
  String _orderType = '';
  String _beat = '';
  String _dr = '';
  String _ackNo = '';
  DateTime? _ackDate;
  double _otherDiscount = 0.0;
  double _creditAdj = 0.0;

  final _docNoController = TextEditingController();
  final _orderTypeController = TextEditingController();
  final _beatController = TextEditingController();
  final _drController = TextEditingController();
  final _ackNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingInvoice != null) {
      _loadExistingInvoice();
    }
  }

  void _loadExistingInvoice() async {
    final inv = widget.existingInvoice!;
    final billerProvider = Provider.of<BillerProvider>(context, listen: false);
    _selectedBiller = await billerProvider.getBillerById(inv.customerId!);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    _lineItems = await invoiceProvider.getInvoiceItems(inv.id!);
    _paymentMode = inv.paymentMode;
    _invoiceDate = inv.invoiceDate;
    _deliveryDate = inv.deliveryDate;
    _docNo = inv.docNo ?? '';
    _orderType = inv.orderType ?? '';
    _beat = inv.beat ?? '';
    _dr = inv.dr ?? '';
    _ackNo = inv.ackNo ?? '';
    _ackDate = inv.ackDate;
    _otherDiscount = inv.otherDiscount;
    _creditAdj = inv.creditAdj;
    _docNoController.text = _docNo;
    _orderTypeController.text = _orderType;
    _beatController.text = _beat;
    _drController.text = _dr;
    _ackNoController.text = _ackNo;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingInvoice == null ? 'Generate Bill' : 'Edit Bill'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biller selection card
            Card(
              child: ListTile(
                title: Text(_selectedBiller?.name ?? 'Select Biller'),
                subtitle: _selectedBiller != null ? Text(_selectedBiller!.customerCode) : null,
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: _selectBiller,
              ),
            ),
            SizedBox(height: 16),

            // Invoice details card
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Doc No'),
                            controller: _docNoController,
                            onChanged: (v) => _docNo = v,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: _paymentMode,
                            items: _paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (v) => setState(() => _paymentMode = v!),
                            decoration: InputDecoration(labelText: 'Payment Mode'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('Invoice Date'),
                            subtitle: Text(DateFormat.yMd().format(_invoiceDate)),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _invoiceDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setState(() => _invoiceDate = date);
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text('Delivery Date'),
                            subtitle: Text(DateFormat.yMd().format(_deliveryDate)),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _deliveryDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setState(() => _deliveryDate = date);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Items section card
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addItems,
                        ),
                      ],
                    ),
                    _lineItems.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No items added', style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _lineItems.length,
                            itemBuilder: (ctx, i) {
                              final item = _lineItems[i];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(item.itemName)),
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () => _editLineItem(i),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _removeItem(i),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text('Qty: ${item.quantity}'),
                                          Text('Rate: ${item.rate}'),
                                          Text('Disc%: ${item.discountPercent}'),
                                          Text('Amt: ${item.amount.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Totals card
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', _subtotal),
                    _buildTotalRow('Total Discount', _totalDiscount),
                    _buildTotalRow('Other Discount', _otherDiscount),
                    _buildTotalRow('Total Tax', _totalTax),
                    Divider(),
                    _buildTotalRow('Net Payable', _netPayable, isBold: true),
                    SizedBox(height: 8),
                    Text(_amountInWords, style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _previewPDF,
                  child: Text('Preview PDF'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper getters for totals
  double get _subtotal => _lineItems.fold(0, (sum, item) => sum + item.grossAmt);
  double get _totalDiscount => _lineItems.fold(0, (sum, item) => sum + item.discountAmt);
  double get _totalTax => _lineItems.fold(0, (sum, item) => sum + item.totalTax);
  double get _netPayable => _subtotal - _totalDiscount - _otherDiscount + _totalTax - _creditAdj;
  String get _amountInWords => 'Rupees ${_netPayable.toStringAsFixed(2)} only';

  Widget _buildTotalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
          Text('₹ ${value.toStringAsFixed(2)}', style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  void _selectBiller() async {
    final billers = Provider.of<BillerProvider>(context, listen: false).billers;
    if (billers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No billers found. Add one first.')));
      return;
    }
    Biller? selected = await showDialog<Biller>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Biller'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: billers.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                title: Text(billers[i].name),
                subtitle: Text(billers[i].customerCode),
                onTap: () => Navigator.pop(ctx, billers[i]),
              );
            },
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedBiller = selected;
        _orderType = selected.orderType ?? '';
        _beat = selected.beat ?? '';
        _dr = selected.dr ?? '';
        _orderTypeController.text = _orderType;
        _beatController.text = _beat;
        _drController.text = _dr;
      });
    }
  }

  void _addItems() async {
    final items = Provider.of<ItemProvider>(context, listen: false).items;
    if (items.isEmpty) {
      // Option to add new item on the fly
      bool? addNew = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('No items'),
          content: Text('No items found. Add a new item?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('No')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Yes')),
          ],
        ),
      );
      if (addNew == true) {
        await showDialog(context: context, builder: (_) => Dialog(child: ItemForm()));
        // Items list will refresh via provider, but we still have to show empty message
      }
      return;
    }

    // Multi-select dialog
    List<Item> selectedItems = await showDialog(
      context: context,
      builder: (ctx) {
        List<Item> tempSelected = [];
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text('Select Items'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  bool isSelected = tempSelected.contains(item);
                  return CheckboxListTile(
                    title: Text(item.itemName),
                    subtitle: Text('MRP: ${item.mrp} | Rate: ${item.rate}'),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          tempSelected.add(item);
                        } else {
                          tempSelected.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, tempSelected),
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      List<InvoiceItem> newItems = [];
      for (var item in selectedItems) {
        double qty = 1; // default quantity; you could add a quantity input dialog here
        final line = InvoiceItem(
          itemId: item.id,
          itemName: item.itemName,
          hsnCode: item.hsnCode,
          uom: item.uom,
          mrp: item.mrp,
          rate: item.rate,
          quantity: qty,
          grossAmt: item.rate * qty,
          freeGst: false,
          discountPercent: 0,
          discountAmt: 0,
          otherDiscount: 0,
          taxableAmt: item.rate * qty,
          cgstPercent: item.cgstPercent,
          sgstPercent: item.sgstPercent,
          cgstAmt: item.rate * qty * item.cgstPercent / 100,
          sgstAmt: item.rate * qty * item.sgstPercent / 100,
          totalTax: item.rate * qty * (item.cgstPercent + item.sgstPercent) / 100,
          amount: item.rate * qty * (1 + (item.cgstPercent + item.sgstPercent) / 100),
        );
        newItems.add(line);
      }
      setState(() {
        _lineItems.addAll(newItems);
      });
    }
  }

  void _editLineItem(int index) {
    final item = _lineItems[index];
    TextEditingController qtyCtrl = TextEditingController(text: item.quantity.toString());
    TextEditingController discCtrl = TextEditingController(text: item.discountPercent.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: discCtrl,
              decoration: InputDecoration(labelText: 'Discount %'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              double newQty = double.tryParse(qtyCtrl.text) ?? item.quantity;
              double newDisc = double.tryParse(discCtrl.text) ?? item.discountPercent;
              setState(() {
                _lineItems[index] = _lineItems[index].copyWith(
                  quantity: newQty,
                  discountPercent: newDisc,
                  grossAmt: item.rate * newQty,
                  discountAmt: (item.rate * newQty) * newDisc / 100,
                  taxableAmt: (item.rate * newQty) - ((item.rate * newQty) * newDisc / 100),
                  cgstAmt: ((item.rate * newQty) - ((item.rate * newQty) * newDisc / 100)) * item.cgstPercent / 100,
                  sgstAmt: ((item.rate * newQty) - ((item.rate * newQty) * newDisc / 100)) * item.sgstPercent / 100,
                  totalTax: ((item.rate * newQty) - ((item.rate * newQty) * newDisc / 100)) * (item.cgstPercent + item.sgstPercent) / 100,
                  amount: ((item.rate * newQty) - ((item.rate * newQty) * newDisc / 100)) * (1 + (item.cgstPercent + item.sgstPercent) / 100),
                );
              });
              Navigator.pop(ctx);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }

  void _previewPDF() async {
    if (_selectedBiller == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select a biller')));
      return;
    }
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add at least one item')));
      return;
    }

    String invoiceNo;
    if (widget.existingInvoice != null) {
      invoiceNo = widget.existingInvoice!.invoiceNo;
    } else {
      invoiceNo = await InvoiceNumberGenerator.generateInvoiceNumber();
    }

    // Determine organization snapshot fields
    String? orgName, orgAddressLine1, orgAddressLine2, orgGstin, orgPhone, orgFssaiNo, orgPan;
    if (widget.existingInvoice != null) {
      // Keep original snapshot when editing
      orgName = widget.existingInvoice!.orgName;
      orgAddressLine1 = widget.existingInvoice!.orgAddressLine1;
      orgAddressLine2 = widget.existingInvoice!.orgAddressLine2;
      orgGstin = widget.existingInvoice!.orgGstin;
      orgPhone = widget.existingInvoice!.orgPhone;
      orgFssaiNo = widget.existingInvoice!.orgFssaiNo;
      orgPan = widget.existingInvoice!.orgPan;
    } else {
      // For new invoice, fetch current organization
      final org = await Provider.of<OrganizationProvider>(context, listen: false).getOrganization();
      orgName = org.name;
      orgAddressLine1 = org.addressLine1;
      orgAddressLine2 = org.addressLine2;
      orgGstin = org.gstin;
      orgPhone = org.phone;
      orgFssaiNo = org.fssaiNo;
      orgPan = org.pan;
    }

    final invoice = Invoice(
      id: widget.existingInvoice?.id,
      invoiceNo: invoiceNo,
      invoiceDate: _invoiceDate,
      deliveryDate: _deliveryDate,
      paymentMode: _paymentMode,
      docNo: _docNo.isNotEmpty ? _docNo : null,
      customerId: _selectedBiller!.id,
      customerName: _selectedBiller!.name,
      orgName: orgName,
      orgAddressLine1: orgAddressLine1,
      orgAddressLine2: orgAddressLine2,
      orgGstin: orgGstin,
      orgPhone: orgPhone,
      orgFssaiNo: orgFssaiNo,
      orgPan: orgPan,
      orderType: _orderType.isNotEmpty ? _orderType : null,
      beat: _beat.isNotEmpty ? _beat : null,
      dr: _dr.isNotEmpty ? _dr : null,
      ackNo: _ackNo.isNotEmpty ? _ackNo : null,
      ackDate: _ackDate,
      totalDiscount: _totalDiscount,
      otherDiscount: _otherDiscount,
      totalTax: _totalTax,
      roundOff: 0,
      netPayable: _netPayable,
      amountInWords: _amountInWords,
      creditAdj: _creditAdj,
      createdAt: widget.existingInvoice?.createdAt ?? DateTime.now(),
    );

    final pdfFile = await PdfGenerator.generateInvoice(
      invoice: invoice,
      biller: _selectedBiller!,
      items: _lineItems,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          pdfFile: pdfFile,
          invoice: invoice,
          items: _lineItems,
          biller: _selectedBiller!,
        ),
      ),
    );
  }
}