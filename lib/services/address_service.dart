import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/address_model.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Address CRUD against /api/addresses — used by AddressScreen (create/
/// edit) and Profile's location summary (read).
class AddressService {
  AddressService._();
  static final AddressService instance = AddressService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/addresses';

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<AddressListResponse> list() async {
    final headers = await _authHeaders();
    if (headers == null) {
      return AddressListResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return AddressListResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return AddressListResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return AddressListResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }

  Future<AddressResponse> create({
    required String province,
    required String district,
    required String commune,
    required String houseNo,
    String? pickupPoint,
    String? location,
    required String type,
    required bool isDefault,
  }) async {
    return _submit(
      method: 'POST',
      url: baseUrl,
      body: {
        'province': province,
        'district': district,
        'commune': commune,
        'house_no': houseNo,
        if (pickupPoint != null && pickupPoint.isNotEmpty) 'pickup_point': pickupPoint,
        if (location != null && location.isNotEmpty) 'location': location,
        'type': type,
        'is_default': isDefault,
      },
      successStatus: 201,
    );
  }

  Future<AddressResponse> update(
    int id, {
    required String province,
    required String district,
    required String commune,
    required String houseNo,
    String? pickupPoint,
    String? location,
    required String type,
    required bool isDefault,
  }) async {
    return _submit(
      method: 'PUT',
      url: '$baseUrl/$id',
      body: {
        'province': province,
        'district': district,
        'commune': commune,
        'house_no': houseNo,
        if (pickupPoint != null && pickupPoint.isNotEmpty) 'pickup_point': pickupPoint,
        if (location != null && location.isNotEmpty) 'location': location,
        'type': type,
        'is_default': isDefault,
      },
      successStatus: 200,
    );
  }

  Future<AddressResponse> _submit({
    required String method,
    required String url,
    required Map<String, dynamic> body,
    required int successStatus,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return AddressResponse(status: false, message: 'Not logged in.');
    }

    try {
      final request = http.Request(method, Uri.parse(url))
        ..headers.addAll(headers)
        ..body = jsonEncode(body);

      final streamed = await request.send().timeout(ApiConstants.requestTimeout);
      final response = await http.Response.fromStream(streamed);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == successStatus;

      return AddressResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return AddressResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return AddressResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
