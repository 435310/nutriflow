/// ============================================
/// MODELO: MENSAGEM DE CHAT
/// ============================================
class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromPatient; // true = paciente enviou, false = nutricionista enviou
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromPatient,
    this.isRead = false,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    bool? isFromPatient,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromPatient: isFromPatient ?? this.isFromPatient,
      isRead: isRead ?? this.isRead,
    );
  }
}