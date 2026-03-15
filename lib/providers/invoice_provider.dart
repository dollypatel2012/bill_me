import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../database/database_helper.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];
  List<Invoice> _filtered = [];
  final DatabaseHelper _db = DatabaseHelper();

  UnmodifiableListView<Invoice> get invoices => UnmodifiableListView(_invoices);
  UnmodifiableListView<Invoice> get filteredInvoices => UnmodifiableListView(_filtered);

  InvoiceProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      orderBy: 'invoice_date DESC',
    );
    _invoices = maps.map((m) => Invoice.fromMap(m)).toList();
    _filtered = List.from(_invoices);
    notifyListeners();
  }

  Future<Invoice?> getInvoiceById(int id) async {
    final db = await _db.database;
    final maps = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Invoice.fromMap(maps.first);
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await _db.database;
    final maps = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
    return maps.map((m) => InvoiceItem.fromMap(m)).toList();
  }

  Future<void> saveCompleteInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      if (invoice.id == null) {
        invoice.id = await txn.insert('invoices', invoice.toMap());
      } else {
        await txn.update('invoices', invoice.toMap(), where: 'id = ?', whereArgs: [invoice.id]);
        await txn.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [invoice.id]);
      }
      for (var item in items) {
        item.invoiceId = invoice.id;
        await txn.insert('invoice_items', item.toMap());
      }
    });
    await loadInvoices();
  }

  Future<void> deleteInvoice(int id) async {
    final db = await _db.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
    await loadInvoices();
  }

  void searchByCustomer(String query) {
    if (query.isEmpty) {
      _filtered = List.from(_invoices);
    } else {
      _filtered = _invoices.where((inv) =>
        (inv.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
    notifyListeners();
  }

  void filterByDateRange(DateTime start, DateTime end) {
    _filtered = _invoices.where((inv) =>
        inv.invoiceDate.isAfter(start.subtract(const Duration(days: 1))) &&
        inv.invoiceDate.isBefore(end.add(const Duration(days: 1)))
    ).toList();
    notifyListeners();
  }

  void clearSearch() {
    _filtered = List.from(_invoices);
    notifyListeners();
  }
}