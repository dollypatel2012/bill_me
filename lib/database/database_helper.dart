import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/organization.dart';
import '../models/biller.dart';
import '../models/item.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'encryption_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'invoices.db');
    String key = await EncryptionHelper.getKey();
    return await openDatabase(
      path,
      password: key,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE organization (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        address_line1 TEXT,
        address_line2 TEXT,
        city TEXT,
        state_code TEXT,
        state_name TEXT,
        fssai_no TEXT,
        cin TEXT,
        gstin TEXT,
        phone TEXT,
        pan TEXT,
        signature_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE billers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_code TEXT UNIQUE,
        name TEXT,
        address TEXT,
        state_code TEXT,
        state_name TEXT,
        gstin TEXT,
        uid TEXT,
        contact TEXT,
        order_type TEXT,
        beat TEXT,
        dr TEXT,
        ack_no TEXT,
        ack_date INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT,
        hsn_code TEXT,
        uom TEXT,
        mrp REAL,
        rate REAL,
        cgst_percent REAL,
        sgst_percent REAL,
        stock_quantity REAL,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT UNIQUE,
        invoice_date INTEGER,
        delivery_date INTEGER,
        payment_mode TEXT,
        doc_no TEXT,
        customer_id INTEGER,
        order_type TEXT,
        beat TEXT,
        dr TEXT,
        ack_no TEXT,
        ack_date INTEGER,
        total_discount REAL,
        other_discount REAL,
        total_tax REAL,
        round_off REAL,
        net_payable REAL,
        amount_in_words TEXT,
        credit_adj REAL,
        created_at INTEGER,
        FOREIGN KEY (customer_id) REFERENCES billers (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        item_id INTEGER,
        item_name TEXT,
        hsn_code TEXT,
        uom TEXT,
        mrp REAL,
        rate REAL,
        quantity REAL,
        gross_amt REAL,
        free_gst INTEGER,
        discount_percent REAL,
        discount_amt REAL,
        other_discount REAL,
        taxable_amt REAL,
        cgst_percent REAL,
        cgst_amt REAL,
        sgst_percent REAL,
        sgst_amt REAL,
        total_tax REAL,
        amount REAL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL
      )
    ''');

    // Insert default organization row
    await db.insert('organization', Organization.defaultOrg().toMap());
  }

  // Generic CRUD methods (you can expand)
}