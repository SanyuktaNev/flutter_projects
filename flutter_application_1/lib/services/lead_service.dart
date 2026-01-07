import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_status.dart';
import 'auth_service.dart';

class LeadStatusService {
  static const String getLeadStatusUrl =
      'https://test836.intellect-logic.com/assomo_crm/apis/get_lead_status.php';
  static const String addLeadStatusUrl =
      'https://test836.intellect-logic.com/assomo_crm/apis/add_lead_status.php';
  static const String editLeadStatusUrl =
      'https://test836.intellect-logic.com/assomo_crm/apis/edit_lead_status.php';
  static const String deleteLeadStatusUrl =
      'https://test836.intellect-logic.com/assomo_crm/apis/delete_lead_status.php';

  // ---------------- HEADERS ----------------
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ---------------- AUTH PAYLOAD ----------------
  Future<Map<String, dynamic>> _authPayload() async {
    final payload = await AuthService.getAuthPayload();
    if (payload == null) {
      throw Exception('Session expired. Please login again.');
    }
    return payload;
  }

  // ---------------- GET ----------------
  Future<Map<String, dynamic>> getLeadStatuses() async {
    try {
      final payload = await _authPayload();

      final response = await http.post(
        Uri.parse(getLeadStatusUrl),
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['response_code'] == 1) {
        final list = jsonData['lead_status_list'] as List;
        final data = list
            .map(
              (e) => LeadStatus(
                id: int.parse(e['lead_status_id'].toString()),
                name: e['name'].toString(),
              ),
            )
            .toList();

        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'error': jsonData['message'] ?? 'Failed to load',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------- ADD ----------------
  Future<Map<String, dynamic>> addLeadStatus(String name) async {
    try {
      final payload = await _authPayload();
      payload['name'] = name;

      final response = await http.post(
        Uri.parse(addLeadStatusUrl),
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['response_code'] == 1) {
        return {'success': true};
      }

      return {'success': false, 'error': jsonData['message']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------- EDIT ----------------
  Future<Map<String, dynamic>> editLeadStatus(int id, String name) async {
    try {
      final payload = await _authPayload();
      payload['lead_status_id'] = id;
      payload['name'] = name;

      final response = await http.post(
        Uri.parse(editLeadStatusUrl),
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['response_code'] == 1) {
        return {'success': true};
      }

      return {'success': false, 'error': jsonData['message']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------- DELETE ----------------
  Future<Map<String, dynamic>> deleteLeadStatus(int id) async {
    try {
      final payload = await _authPayload();
      payload['lead_status_id'] = id;

      final response = await http.post(
        Uri.parse(deleteLeadStatusUrl),
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['response_code'] == 1) {
        return {'success': true};
      }

      return {'success': false, 'error': jsonData['message']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
