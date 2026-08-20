import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/prediction_result.dart';
import '../models/advice.dart';
import '../models/doctor.dart';

/// The ONLY class in this app that knows HTTP exists.
/// When we move to offline inference later, this file gets replaced
/// (or its internals swapped) - nothing above it (repositories, providers,
/// screens) needs to change, as long as the method signatures stay the same.
class ApiService {
  Future<PredictionResult> predict({
    required List<String> symptoms,
    List<String> deniedSymptoms = const [],
    int followupRound = 0,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/predict');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'symptoms': symptoms,
            'denied_symptoms': deniedSymptoms,
            'followup_round': followupRound,
          }),
        )
        .timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      return PredictionResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail']?.toString() ?? 'Prediction failed');
    }
  }

  Future<Advice> getAdvice(String disease) async {
    final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/advice/${Uri.encodeComponent(disease)}');
    final response = await http.get(uri).timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      return Advice.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw ApiException('Could not fetch advice for $disease');
    }
  }

  Future<List<Doctor>> getDoctors(String disease) async {
    final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/doctors/${Uri.encodeComponent(disease)}');
    final response = await http.get(uri).timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['doctors'] as List)
          .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException('Could not fetch doctors for $disease');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}