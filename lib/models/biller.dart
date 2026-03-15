class Biller {
  int? id;
  String customerCode;
  String name;
  String address;
  String stateCode;
  String stateName;
  String? gstin;
  String? uid;
  String? contact;
  String? orderType;
  String? beat;
  String? dr;
  String? ackNo;
  DateTime? ackDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Biller({
    this.id,
    required this.customerCode,
    required this.name,
    required this.address,
    required this.stateCode,
    required this.stateName,
    this.gstin,
    this.uid,
    this.contact,
    this.orderType,
    this.beat,
    this.dr,
    this.ackNo,
    this.ackDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_code': customerCode,
      'name': name,
      'address': address,
      'state_code': stateCode,
      'state_name': stateName,
      'gstin': gstin,
      'uid': uid,
      'contact': contact,
      'order_type': orderType,
      'beat': beat,
      'dr': dr,
      'ack_no': ackNo,
      'ack_date': ackDate?.millisecondsSinceEpoch,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Biller.fromMap(Map<String, dynamic> map) {
    return Biller(
      id: map['id'],
      customerCode: map['customer_code'],
      name: map['name'],
      address: map['address'],
      stateCode: map['state_code'],
      stateName: map['state_name'],
      gstin: map['gstin'],
      uid: map['uid'],
      contact: map['contact'],
      orderType: map['order_type'],
      beat: map['beat'],
      dr: map['dr'],
      ackNo: map['ack_no'],
      ackDate: map['ack_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['ack_date']) : null,
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) : null,
    );
  }
}