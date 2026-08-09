class Address {
  final int id;
  final String province;
  final String district;
  final String commune;
  final String houseNo;
  final String? pickupPoint;
  final String? location;
  final String type;
  final bool isDefault;

  Address({
    required this.id,
    required this.province,
    required this.district,
    required this.commune,
    required this.houseNo,
    this.pickupPoint,
    this.location,
    required this.type,
    required this.isDefault,
  });

  /// Same flattened format the Profile card's location line has always
  /// shown (house no, commune, district) — kept identical so wiring in
  /// the real API doesn't change how it looks on screen.
  String get formatted => [houseNo, commune, district].where((part) => part.isNotEmpty).join(', ');

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      commune: json['commune'] ?? '',
      houseNo: json['house_no'] ?? '',
      pickupPoint: json['pickup_point'],
      location: json['location'],
      type: json['type'] ?? 'home',
      isDefault: json['is_default'] ?? false,
    );
  }
}

class AddressResponse {
  final bool status;
  final String message;
  final Address? address;

  AddressResponse({required this.status, required this.message, this.address});

  factory AddressResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return AddressResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      address: json['data'] != null ? Address.fromJson(json['data']) : null,
    );
  }
}

class AddressListResponse {
  final bool status;
  final String message;
  final List<Address> addresses;

  AddressListResponse({required this.status, required this.message, this.addresses = const []});

  factory AddressListResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return AddressListResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      addresses: json['data'] != null
          ? (json['data'] as List).map((e) => Address.fromJson(e)).toList()
          : const [],
    );
  }
}
