class InvoiceItem {
  int? id;
  int? invoiceId;
  int? itemId;
  String itemName;
  String? hsnCode;
  String uom;
  double mrp;
  double rate;
  double quantity;
  double grossAmt;
  bool freeGst;
  double discountPercent;
  double discountAmt;
  double otherDiscount;
  double taxableAmt;
  double cgstPercent;
  double cgstAmt;
  double sgstPercent;
  double sgstAmt;
  double totalTax;
  double amount;

  InvoiceItem({
    this.id,
    this.invoiceId,
    this.itemId,
    required this.itemName,
    this.hsnCode,
    required this.uom,
    required this.mrp,
    required this.rate,
    required this.quantity,
    required this.grossAmt,
    required this.freeGst,
    required this.discountPercent,
    required this.discountAmt,
    required this.otherDiscount,
    required this.taxableAmt,
    required this.cgstPercent,
    required this.cgstAmt,
    required this.sgstPercent,
    required this.sgstAmt,
    required this.totalTax,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'item_name': itemName,
      'hsn_code': hsnCode,
      'uom': uom,
      'mrp': mrp,
      'rate': rate,
      'quantity': quantity,
      'gross_amt': grossAmt,
      'free_gst': freeGst ? 1 : 0,
      'discount_percent': discountPercent,
      'discount_amt': discountAmt,
      'other_discount': otherDiscount,
      'taxable_amt': taxableAmt,
      'cgst_percent': cgstPercent,
      'cgst_amt': cgstAmt,
      'sgst_percent': sgstPercent,
      'sgst_amt': sgstAmt,
      'total_tax': totalTax,
      'amount': amount,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoice_id'],
      itemId: map['item_id'],
      itemName: map['item_name'],
      hsnCode: map['hsn_code'],
      uom: map['uom'],
      mrp: map['mrp'],
      rate: map['rate'],
      quantity: map['quantity'],
      grossAmt: map['gross_amt'],
      freeGst: map['free_gst'] == 1,
      discountPercent: map['discount_percent'],
      discountAmt: map['discount_amt'],
      otherDiscount: map['other_discount'],
      taxableAmt: map['taxable_amt'],
      cgstPercent: map['cgst_percent'],
      cgstAmt: map['cgst_amt'],
      sgstPercent: map['sgst_percent'],
      sgstAmt: map['sgst_amt'],
      totalTax: map['total_tax'],
      amount: map['amount'],
    );
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? itemId,
    String? itemName,
    String? hsnCode,
    String? uom,
    double? mrp,
    double? rate,
    double? quantity,
    double? grossAmt,
    bool? freeGst,
    double? discountPercent,
    double? discountAmt,
    double? otherDiscount,
    double? taxableAmt,
    double? cgstPercent,
    double? cgstAmt,
    double? sgstPercent,
    double? sgstAmt,
    double? totalTax,
    double? amount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      hsnCode: hsnCode ?? this.hsnCode,
      uom: uom ?? this.uom,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
      quantity: quantity ?? this.quantity,
      grossAmt: grossAmt ?? this.grossAmt,
      freeGst: freeGst ?? this.freeGst,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmt: discountAmt ?? this.discountAmt,
      otherDiscount: otherDiscount ?? this.otherDiscount,
      taxableAmt: taxableAmt ?? this.taxableAmt,
      cgstPercent: cgstPercent ?? this.cgstPercent,
      cgstAmt: cgstAmt ?? this.cgstAmt,
      sgstPercent: sgstPercent ?? this.sgstPercent,
      sgstAmt: sgstAmt ?? this.sgstAmt,
      totalTax: totalTax ?? this.totalTax,
      amount: amount ?? this.amount,
    );
  }
}