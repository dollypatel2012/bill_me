import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../database/database_helper.dart';

class OrganizationProvider extends ChangeNotifier {
  Organization? _organization;

  Organization? get organization => _organization;

  Future<Organization> getOrganization() async {
    if (_organization != null) return _organization!;
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('organization', where: 'id = 1');
    if (maps.isNotEmpty) {
      _organization = Organization.fromMap(maps.first);
    } else {
      _organization = Organization.defaultOrg();
      await db.insert('organization', _organization!.toMap());
    }
    return _organization!;
  }

  Future<void> updateOrganization(Organization org) async {
    final db = await DatabaseHelper().database;
    await db.update('organization', org.toMap(), where: 'id = ?', whereArgs: [org.id]);
    _organization = org;
    notifyListeners();
  }
}