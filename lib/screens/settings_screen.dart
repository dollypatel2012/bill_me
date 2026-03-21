import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/organization_provider.dart';
import '../models/organization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late Organization _org;
  bool _isLoading = true;

  // Controllers for each field
  late TextEditingController _nameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateCodeController;
  late TextEditingController _stateNameController;
  late TextEditingController _fssaiNoController;
  late TextEditingController _cinController;
  late TextEditingController _gstinController;
  late TextEditingController _phoneController;
  late TextEditingController _panController;

  @override
  void initState() {
    super.initState();
    _loadOrg();
  }

  Future<void> _loadOrg() async {
    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    _org = await provider.getOrganization();
    _initControllers();
    setState(() => _isLoading = false);
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _org.name);
    _addressLine1Controller = TextEditingController(text: _org.addressLine1);
    _addressLine2Controller = TextEditingController(text: _org.addressLine2 ?? '');
    _cityController = TextEditingController(text: _org.city ?? '');
    _stateCodeController = TextEditingController(text: _org.stateCode);
    _stateNameController = TextEditingController(text: _org.stateName);
    _fssaiNoController = TextEditingController(text: _org.fssaiNo);
    _cinController = TextEditingController(text: _org.cin ?? '');
    _gstinController = TextEditingController(text: _org.gstin);
    _phoneController = TextEditingController(text: _org.phone);
    _panController = TextEditingController(text: _org.pan);
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/signature_${_org.id}.jpg');
      await File(picked.path).copy(file.path);
      setState(() {
        _org.signaturePath = file.path;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final updatedOrg = Organization(
      id: _org.id,
      name: _nameController.text,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text.isNotEmpty ? _addressLine2Controller.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      stateCode: _stateCodeController.text,
      stateName: _stateNameController.text,
      fssaiNo: _fssaiNoController.text,
      cin: _cinController.text.isNotEmpty ? _cinController.text : null,
      gstin: _gstinController.text,
      phone: _phoneController.text,
      pan: _panController.text,
      signaturePath: _org.signaturePath,
    );

    await Provider.of<OrganizationProvider>(context, listen: false)
        .updateOrganization(updatedOrg);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
    Navigator.pop(context); // optionally go back
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Organization Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Business Name *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(labelText: 'Address Line 1 *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(labelText: 'Address Line 2 (optional)'),
            ),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City (optional)'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stateCodeController,
                    decoration: const InputDecoration(labelText: 'State Code *'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _stateNameController,
                    decoration: const InputDecoration(labelText: 'State Name *'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _fssaiNoController,
              decoration: const InputDecoration(labelText: 'FSSAI No *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _cinController,
              decoration: const InputDecoration(labelText: 'CIN (optional)'),
            ),
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(labelText: 'GSTIN *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone *'),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(labelText: 'PAN *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Signature'),
              subtitle: _org.signaturePath != null
                  ? Image.file(File(_org.signaturePath!), height: 50)
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.upload),
                onPressed: _pickSignature,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}