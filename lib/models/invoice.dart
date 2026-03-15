class Invoice {
  int? id;
  String invoiceNo;
  DateTime invoiceDate;
  DateTime deliveryDate;
  String paymentMode;
  String? docNo;
  int? customerId;
  String? customerName; // denormalized
  String? orderType;
  String? beat;
  String? dr;
  String? ackNo;
  DateTime? ackDate;
  double totalDiscount;
  double otherDiscount;
  double totalTax;
  double roundOff;
  double netPayable;
  String amountInWords;
  double creditAdj;
  DateTime? createdAt;

  Invoice({
    this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.deliveryDate,
    required this.paymentMode,
    this.docNo,
    this.customerId,
    this.customerName,
    this.orderType,
    this.beat,
    this.dr,
    this.ackNo,
    this.ackDate,
    required this.totalDiscount,
    required this.otherDiscount,
    required this.totalTax,
    required this.roundOff,
    required this.netPayable,
    required this.amountInWords,
    required this.creditAdj,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate.millisecondsSinceEpoch,
      'delivery_date': deliveryDate.millisecondsSinceEpoch,
      'payment_mode': paymentMode,
      'doc_no': docNo,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_type': orderType,
      'beat': beat,
      'dr': dr,
      'ack_no': ackNo,
      'ack_date': ackDate?.millisecondsSinceEpoch,
      'total_discount': totalDiscount,
      'other_discount': otherDiscount,
      'total_tax': totalTax,
      'round_off': roundOff,
      'net_payable': netPayable,
      'amount_in_words': amountInWords,
      'credit_adj': creditAdj,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNo: map['invoice_no'],
      invoiceDate: DateTime.fromMillisecondsSinceEpoch(map['invoice_date']),
      deliveryDate: DateTime.fromMillisecondsSinceEpoch(map['delivery_date']),
      paymentMode: map['payment_mode'],
      docNo: map['doc_no'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      orderType: map['order_type'],
      beat: map['beat'],
      dr: map['dr'],
      ackNo: map['ack_no'],
      ackDate: map['ack_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['ack_date']) : null,
      totalDiscount: map['total_discount'],
      otherDiscount: map['other_discount'],
      totalTax: map['total_tax'],
      roundOff: map['round_off'],
      netPayable: map['net_payable'],
      amountInWords: map['amount_in_words'],
      creditAdj: map['credit_adj'],
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
    );
  }
}