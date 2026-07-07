import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSource(this._dioClient);

  /// Mengirim pesan secara instan (mengembalikan respons lengkap langsung)
  Future<String> sendMessageInstant(ChatMessageModel message, String model, List<ChatMessageModel> history, {bool webSearch = false}) async {
    final Map<String, dynamic> data = message.toJson();
    data['model'] = model;
    data['webSearch'] = webSearch;
    data['history'] = history.map((m) => {
      'sender': m.sender == 'user' ? 'user' : 'assistant',
      'message': m.message,
    }).toList();

    final response = await _dioClient.dio.post(
      '/chat',
      data: data,
    );

    final reply = response.data?['reply'];
    if (reply == null) {
      throw const FormatException('Format respons instan tidak valid');
    }
    return reply as String;
  }

  /// Mentranskripsi rekaman suara audio menggunakan API Whisper di backend
  Future<String> transcribeAudio(String base64Audio, String format) async {
    final response = await _dioClient.dio.post(
      '/chat/transcribe',
      data: {
        'audio': base64Audio,
        'format': format,
      },
    );

    final text = response.data?['text'];
    if (text == null) {
      throw const FormatException('Format respons transkripsi tidak valid');
    }
    return text as String;
  }

  /// Mengirim pesan dengan streaming (mengembalikan Stream token kata demi kata)
  Stream<String> sendMessageStream(ChatMessageModel message, String model, List<ChatMessageModel> history, {bool webSearch = false}) {
    final controller = StreamController<String>();

    _executeStreamRequest(message, model, history, controller, webSearch: webSearch);

    return controller.stream;
  }

  /// Menjalankan request streaming Dio dan mem-parsing Server-Sent Events (SSE)
  void _executeStreamRequest(
    ChatMessageModel message,
    String model,
    List<ChatMessageModel> history,
    StreamController<String> controller, {
    bool webSearch = false,
  }) async {
    try {
      final Map<String, dynamic> data = message.toJson();
      data['model'] = model;
      data['webSearch'] = webSearch;
      data['history'] = history.map((m) => {
        'sender': m.sender == 'user' ? 'user' : 'assistant',
        'message': m.message,
      }).toList();

      final response = await _dioClient.dio.post<ResponseBody>(
        '/chat/stream',
        data: data,
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        controller.addError(const FormatException('Gagal mendapatkan aliran data stream dari server'));
        await controller.close();
        return;
      }

      final lineStream = stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter());
      
      bool inThought = false;

      final subscription = lineStream.listen(
        (String line) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) return;

          // Jika baris berisi [DONE], matikan stream
          if (trimmedLine == 'data: [DONE]') {
            if (inThought) {
              controller.add('</thought>');
              inThought = false;
            }
            controller.close();
            return;
          }

          // Jika baris dimulai dengan data:
          if (trimmedLine.startsWith('data:')) {
            final jsonStr = trimmedLine.substring(5).trim();
            if (jsonStr.startsWith('[ERROR]')) {
              controller.addError(FormatException(jsonStr));
              return;
            }

            try {
              final Map<String, dynamic> dataMap = jsonDecode(jsonStr);
              final choices = dataMap['choices'] as List?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map?;
                
                // Cek reasoning_content (proses berpikir)
                final reasoningContent = delta?['reasoning_content'] as String?;
                if (reasoningContent != null && reasoningContent.isNotEmpty) {
                  if (!inThought) {
                    inThought = true;
                    controller.add('<thought>');
                  }
                  controller.add(reasoningContent);
                }

                // Cek content (jawaban utama)
                final content = delta?['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  if (inThought) {
                    inThought = false;
                    controller.add('</thought>');
                  }
                  controller.add(content);
                }
              }
            } catch (_) {
              // Abaikan kesalahan parse JSON untuk baris kosong atau keep-alive comments
            }
          }
        },
        onError: (error) {
          if (inThought) {
            controller.add('</thought>');
          }
          controller.addError(error);
          controller.close();
        },
        onDone: () {
          if (inThought) {
            controller.add('</thought>');
          }
          if (!controller.isClosed) {
            controller.close();
          }
        },
        cancelOnError: true,
      );

      // Pastikan stream dibatalkan jika subscription di-close
      controller.onCancel = () {
        subscription.cancel();
      };

    } on DioException catch (e) {
      controller.addError(e);
      controller.close();
    } catch (e) {
      controller.addError(e);
      controller.close();
    }
  }
}
