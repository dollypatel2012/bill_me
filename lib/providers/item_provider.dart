import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../database/database_helper.dart';

class ItemProvider extends ChangeNotifier {
  List<Item> _items = [];
  List<Item> _filtered = [];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);
  UnmodifiableListView<Item> get filteredItems => UnmodifiableListView(_filtered);

  ItemProvider() {
    loadItems();
  }

  Future<void> loadItems() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('items', orderBy: 'item_name');
    _items = maps.map((m) => Item.fromMap(m)).toList();
    _filtered = List.from(_items);
    notifyListeners();
  }

  Future<Item?> getItemById(int id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Item.fromMap(maps.first);
  }

  Future<void> saveItem(Item item) async {
    final db = await DatabaseHelper().database;
    if (item.id == null) {
      await db.insert('items', item.toMap());
    } else {
      await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    }
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    await loadItems();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filtered = List.from(_items);
    } else {
      _filtered = _items.where((i) =>
        i.itemName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}