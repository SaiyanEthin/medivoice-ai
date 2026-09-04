import 'prediction_result.dart';

enum ChatRole { app, user }

enum ChatKind { text, questions, result }

/// One entry in the consultation thread.
///
/// The thread is purely a view of what already happened - the provider
/// remains the single source of truth for symptoms, rounds and results.
class ChatMessage {
  final ChatRole role;
  final ChatKind kind;
  final String text;
  final List<FollowUpQuestion> questions;
  final PredictionResult? result;

  /// Set once a question batch has been submitted, which freezes the
  /// bubble into a read-only summary of what was answered.
  Map<String, bool>? submittedAnswers;

  ChatMessage.app(this.text)
      : role = ChatRole.app,
        kind = ChatKind.text,
        questions = const [],
        result = null;

  ChatMessage.user(this.text)
      : role = ChatRole.user,
        kind = ChatKind.text,
        questions = const [],
        result = null;

  ChatMessage.questions(this.questions)
      : role = ChatRole.app,
        kind = ChatKind.questions,
        text = '',
        result = null;

  ChatMessage.result(this.result)
      : role = ChatRole.app,
        kind = ChatKind.result,
        text = '',
        questions = const [];

  bool get isAnswered => submittedAnswers != null;
}
