import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../providers/item_provider.dart';
import 'package:provider/provider.dart';

class ItemForm extends StatefulWidget {
  final Item? item;
  ItemForm({this.item});

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _uomController;
  late TextEditingController _mrpController;
  late TextEditingController _rateController;
  late TextEditingController _cgstController;
  late TextEditingController _sgstController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameController = TextEditingController(text: i?.itemName ?? '');
    _hsnController = TextEditingController(text: i?.hsnCode ?? '');
    _uomController = TextEditingController(text: i?.uom ?? 'PAC');
    _mrpController = TextEditingController(text: i?.mrp.toString() ?? '');
    _rateController = TextEditingController(text: i?.rate.toString() ?? '');
    _cgstController = TextEditingController(text: i?.cgstPercent.toString() ?? '9.25');
    _sgstController = TextEditingController(text: i?.sgstPercent.toString() ?? '9.25');
    _stockController = TextEditingController(text: i?.stockQuantity.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hsnController,
                  decoration: const InputDecoration(labelText: 'HSN Code'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _uomController,
                  decoration: const InputDecoration(labelText: 'UOM *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mrpController,
                  decoration: const InputDecoration(labelText: 'MRP *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(labelText: 'Selling Rate *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cgstController,
                        decoration: const InputDecoration(labelText: 'CGST %'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sgstController,
                        decoration: const InputDecoration(labelText: 'SGST %'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final item = Item(
      id: widget.item?.id,
      itemName: _nameController.text,
      hsnCode: _hsnController.text.isNotEmpty ? _hsnController.text : null,
      uom: _uomController.text,
      mrp: double.parse(_mrpController.text),
      rate: double.parse(_rateController.text),
      cgstPercent: double.parse(_cgstController.text),
      sgstPercent: double.parse(_sgstController.text),
      stockQuantity: double.parse(_stockController.text),
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Provider.of<ItemProvider>(context, listen: false).saveItem(item);
    Navigator.pop(context);
  }
}