class Item {
  int? id;
  String itemName;
  String? hsnCode;
  String uom;
  double mrp;
  double rate;
  double cgstPercent;
  double sgstPercent;
  double stockQuantity;
  DateTime? createdAt;
  DateTime? updatedAt;

  Item({
    this.id,
    required this.itemName,
    this.hsnCode,
    required this.uom,
    required this.mrp,
    required this.rate,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.stockQuantity,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'hsn_code': hsnCode,
      'uom': uom,
      'mrp': mrp,
      'rate': rate,
      'cgst_percent': cgstPercent,
      'sgst_percent': sgstPercent,
      'stock_quantity': stockQuantity,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      itemName: map['item_name'],
      hsnCode: map['hsn_code'],
      uom: map['uom'],
      mrp: map['mrp'],
      rate: map['rate'],
      cgstPercent: map['cgst_percent'],
      sgstPercent: map['sgst_percent'],
      stockQuantity: map['stock_quantity'],
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) : null,
    );
  }
}