import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String sender; // 'user' | 'bot'
  final String message;
  final String? imageBase64; // base64 string
  final String? pdfBase64;   // base64 string
  final String? audioBase64; // base64 string
  final String? model;       // AI model ID used
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    this.imageBase64,
    this.pdfBase64,
    this.audioBase64,
    this.model,
    required this.timestamp,
  });

  ChatMessageModel copyWith({
    String? id,
    String? sender,
    String? message,
    String? imageBase64,
    String? pdfBase64,
    String? audioBase64,
    String? model,
    DateTime? timestamp,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      imageBase64: imageBase64 ?? this.imageBase64,
      pdfBase64: pdfBase64 ?? this.pdfBase64,
      audioBase64: audioBase64 ?? this.audioBase64,
      model: model ?? this.model,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (imageBase64 != null) 'image': imageBase64,
      if (pdfBase64 != null) 'pdf': pdfBase64,
      if (audioBase64 != null) 'audio': audioBase64,
      if (model != null) 'model': model,
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'imageBase64': imageBase64,
      'pdfBase64': pdfBase64,
      'audioBase64': audioBase64,
      'model': model,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromLocalJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sender: json['sender'] as String,
      message: json['message'] as String,
      imageBase64: json['imageBase64'] as String?,
      pdfBase64: json['pdfBase64'] as String?,
      audioBase64: json['audioBase64'] as String?,
      model: json['model'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        message,
        imageBase64,
        pdfBase64,
        audioBase64,
        model,
        timestamp,
      ];
}
