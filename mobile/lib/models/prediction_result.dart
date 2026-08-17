class DiseaseConfidence {
  final String disease;
  final double confidence;

  DiseaseConfidence({required this.disease, required this.confidence});

  factory DiseaseConfidence.fromJson(Map<String, dynamic> json) {
    return DiseaseConfidence(
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class FollowUpQuestion {
  final String symptom;   // raw column name - send back as-is if answered "Yes"
  final String question;  // human-readable text to show the user

  FollowUpQuestion({required this.symptom, required this.question});

  factory FollowUpQuestion.fromJson(Map<String, dynamic> json) {
    return FollowUpQuestion(
      symptom: json['symptom'] as String,
      question: json['question'] as String,
    );
  }
}

class PredictionResult {
  final DiseaseConfidence topPrediction;
  final List<DiseaseConfidence> allPredictions;
  final bool needsFollowup;
  final List<FollowUpQuestion> followUpQuestions;

  PredictionResult({
    required this.topPrediction,
    required this.allPredictions,
    required this.needsFollowup,
    required this.followUpQuestions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      topPrediction: DiseaseConfidence.fromJson(json['top_prediction']),
      allPredictions: (json['all_predictions'] as List)
          .map((e) => DiseaseConfidence.fromJson(e))
          .toList(),
      needsFollowup: json['needs_followup'] as bool,
      followUpQuestions: (json['follow_up_questions'] as List)
          .map((e) => FollowUpQuestion.fromJson(e))
          .toList(),
    );
  }
}
