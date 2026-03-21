import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'encryption_helper.dart';
import '../models/organization.dart'; // for default organization

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
      version: 3, // Incremented to 3 for organization snapshot columns
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Organization table (singleton)
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

    // Billers table
    await db.execute('''
      CREATE TABLE billers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
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

    // Items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
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

    // Invoices table with customer_name and organization snapshot columns
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT UNIQUE NOT NULL,
        invoice_date INTEGER NOT NULL,
        delivery_date INTEGER NOT NULL,
        payment_mode TEXT,
        doc_no TEXT,
        customer_id INTEGER,
        customer_name TEXT,
        -- Organization snapshot columns
        org_name TEXT,
        org_address_line1 TEXT,
        org_address_line2 TEXT,
        org_gstin TEXT,
        org_phone TEXT,
        org_fssai_no TEXT,
        org_pan TEXT,
        -- Other existing fields
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

    // Invoice items table
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
        item_name TEXT,
        hsn_code TEXT,
        uom TEXT,
        mrp REAL,
        rate REAL,
        quantity REAL,
        gross_amt REAL,
        free_gst INTEGER DEFAULT 0,
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

    // Insert default organization
    await db.insert('organization', Organization.defaultOrg().toMap());
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrate from version 1 to 2: add customer_name column
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE invoices ADD COLUMN customer_name TEXT');
        print('✅ Added customer_name column to invoices table');
      } catch (e) {
        print('⚠️ Error adding customer_name column: $e (maybe already exists)');
      }
    }
    // Migrate from version 2 to 3: add organization snapshot columns
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE invoices ADD COLUMN org_name TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_address_line1 TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_address_line2 TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_gstin TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_phone TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_fssai_no TEXT');
        await db.execute('ALTER TABLE invoices ADD COLUMN org_pan TEXT');
        print('✅ Added organization snapshot columns to invoices table');
      } catch (e) {
        print('⚠️ Error adding snapshot columns: $e');
      }
    }
    // Add more migrations here for future versions
  }
}