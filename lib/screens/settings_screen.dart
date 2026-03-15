import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';   // <-- Add this
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/organization_provider.dart';
import '../models/organization.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late Organization org;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrg();
  }

  Future<void> _loadOrg() async {
    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    org = await provider.getOrganization();
    setState(() => _isLoading = false);
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Save image to app documents
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/signature${org.id}.jpg');
      await File(picked.path).copy(file.path);
      setState(() {
        org.signaturePath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: org.name,
              decoration: InputDecoration(labelText: 'Business Name'),
              onSaved: (v) => org.name = v!,
            ),
            // Add all other fields similarly...
            ListTile(
              title: Text('Signature'),
              subtitle: org.signaturePath != null ? Image.file(File(org.signaturePath!), height: 50) : null,
              trailing: IconButton(
                icon: Icon(Icons.upload),
                onPressed: _pickSignature,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Provider.of<OrganizationProvider>(context, listen: false).updateOrganization(org);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved')));
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}