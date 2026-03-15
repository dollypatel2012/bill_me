import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/biller.dart';
import '../database/database_helper.dart';

class BillerProvider extends ChangeNotifier {
  List<Biller> _billers = [];
  List<Biller> _filtered = [];

  UnmodifiableListView<Biller> get billers => UnmodifiableListView(_billers);
  UnmodifiableListView<Biller> get filteredBillers => UnmodifiableListView(_filtered);

  BillerProvider() {
    loadBillers();
  }

  Future<void> loadBillers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('billers', orderBy: 'name');
    _billers = maps.map((m) => Biller.fromMap(m)).toList();
    _filtered = List.from(_billers);
    notifyListeners();
  }

  Future<Biller?> getBillerById(int id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('billers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Biller.fromMap(maps.first);
  }

  Future<void> saveBiller(Biller biller) async {
    final db = await DatabaseHelper().database;
    if (biller.id == null) {
      await db.insert('billers', biller.toMap());
    } else {
      await db.update('billers', biller.toMap(), where: 'id = ?', whereArgs: [biller.id]);
    }
    await loadBillers();
  }

  Future<void> deleteBiller(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('billers', where: 'id = ?', whereArgs: [id]);
    await loadBillers();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filtered = List.from(_billers);
    } else {
      _filtered = _billers.where((b) =>
        b.name.toLowerCase().contains(query.toLowerCase()) ||
        b.customerCode.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}