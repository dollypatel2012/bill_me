import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/biller.dart';
import '../../providers/biller_provider.dart';
import 'package:provider/provider.dart';

class BillerForm extends StatefulWidget {
  final Biller? biller;
  BillerForm({this.biller});

  @override
  _BillerFormState createState() => _BillerFormState();
}

class _BillerFormState extends State<BillerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _stateCodeController;
  late TextEditingController _stateNameController;
  late TextEditingController _gstinController;
  late TextEditingController _uidController;
  late TextEditingController _contactController;
  late TextEditingController _orderTypeController;
  late TextEditingController _beatController;
  late TextEditingController _drController;
  late TextEditingController _ackNoController;
  DateTime? _ackDate;

  @override
  void initState() {
    super.initState();
    final b = widget.biller;
    _codeController = TextEditingController(text: b?.customerCode ?? '');
    _nameController = TextEditingController(text: b?.name ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');
    _stateCodeController = TextEditingController(text: b?.stateCode ?? '23');
    _stateNameController = TextEditingController(text: b?.stateName ?? 'Madhya Pradesh');
    _gstinController = TextEditingController(text: b?.gstin ?? '');
    _uidController = TextEditingController(text: b?.uid ?? '');
    _contactController = TextEditingController(text: b?.contact ?? '');
    _orderTypeController = TextEditingController(text: b?.orderType ?? '');
    _beatController = TextEditingController(text: b?.beat ?? '');
    _drController = TextEditingController(text: b?.dr ?? '');
    _ackNoController = TextEditingController(text: b?.ackNo ?? '');
    _ackDate = b?.ackDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(widget.biller == null ? 'Add Biller' : 'Edit Biller',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Customer Code *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address *'),
              maxLines: 2,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stateCodeController,
                    decoration: InputDecoration(labelText: 'State Code'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _stateNameController,
                    decoration: InputDecoration(labelText: 'State Name'),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _gstinController,
              decoration: InputDecoration(labelText: 'GSTIN'),
            ),
            TextFormField(
              controller: _uidController,
              decoration: InputDecoration(labelText: 'UID'),
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _orderTypeController,
              decoration: InputDecoration(labelText: 'Order Type'),
            ),
            TextFormField(
              controller: _beatController,
              decoration: InputDecoration(labelText: 'Beat'),
            ),
            TextFormField(
              controller: _drController,
              decoration: InputDecoration(labelText: 'DR'),
            ),
            TextFormField(
              controller: _ackNoController,
              decoration: InputDecoration(labelText: 'Ack No'),
            ),
            ListTile(
              title: Text('Ack Date: ${_ackDate != null ? DateFormat('dd/MM/yyyy').format(_ackDate!) : 'Not set'}'),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _ackDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _ackDate = date);
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final biller = Biller(
      id: widget.biller?.id,
      customerCode: _codeController.text,
      name: _nameController.text,
      address: _addressController.text,
      stateCode: _stateCodeController.text,
      stateName: _stateNameController.text,
      gstin: _gstinController.text.isNotEmpty ? _gstinController.text : null,
      uid: _uidController.text.isNotEmpty ? _uidController.text : null,
      contact: _contactController.text.isNotEmpty ? _contactController.text : null,
      orderType: _orderTypeController.text.isNotEmpty ? _orderTypeController.text : null,
      beat: _beatController.text.isNotEmpty ? _beatController.text : null,
      dr: _drController.text.isNotEmpty ? _drController.text : null,
      ackNo: _ackNoController.text.isNotEmpty ? _ackNoController.text : null,
      ackDate: _ackDate,
      createdAt: widget.biller?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Provider.of<BillerProvider>(context, listen: false).saveBiller(biller);
    Navigator.pop(context);
  }
}