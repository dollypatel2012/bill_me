class Organization {
  int? id;
  String name;
  String addressLine1;
  String? addressLine2;
  String? city;
  String stateCode;
  String stateName;
  String fssaiNo;
  String? cin;
  String gstin;
  String phone;
  String pan;
  String? signaturePath;

  Organization({
    this.id,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    required this.stateCode,
    required this.stateName,
    required this.fssaiNo,
    this.cin,
    required this.gstin,
    required this.phone,
    required this.pan,
    this.signaturePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state_code': stateCode,
      'state_name': stateName,
      'fssai_no': fssaiNo,
      'cin': cin,
      'gstin': gstin,
      'phone': phone,
      'pan': pan,
      'signature_path': signaturePath,
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['id'],
      name: map['name'],
      addressLine1: map['address_line1'],
      addressLine2: map['address_line2'],
      city: map['city'],
      stateCode: map['state_code'],
      stateName: map['state_name'],
      fssaiNo: map['fssai_no'],
      cin: map['cin'],
      gstin: map['gstin'],
      phone: map['phone'],
      pan: map['pan'],
      signaturePath: map['signature_path'],
    );
  }

  static Organization defaultOrg() {
    return Organization(
      name: 'PRAYAG MARKETING',
      addressLine1: 'HO NO. 115 SHEETAL PURI',
      stateCode: '23',
      stateName: 'Madhya Pradesh',
      fssaiNo: '11425110000217',
      gstin: '23ABHFP9667J1ZM',
      phone: '9893459382',
      pan: 'ABHFP9667J',
    );
  }
}