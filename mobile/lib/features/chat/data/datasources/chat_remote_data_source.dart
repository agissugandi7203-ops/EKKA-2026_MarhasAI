import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSource(this._dioClient);

  /// Mengirim pesan secara instan (mengembalikan respons lengkap langsung)
  Future<String> sendMessageInstant(ChatMessageModel message, String model) async {
    final Map<String, dynamic> data = message.toJson();
    data['model'] = model;

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

  /// Mengirim pesan dengan streaming (mengembalikan Stream token kata demi kata)
  Stream<String> sendMessageStream(ChatMessageModel message, String model) {
    final controller = StreamController<String>();

    _executeStreamRequest(message, model, controller);

    return controller.stream;
  }

  /// Menjalankan request streaming Dio dan mem-parsing Server-Sent Events (SSE)
  void _executeStreamRequest(
    ChatMessageModel message,
    String model,
    StreamController<String> controller,
  ) async {
    try {
      final Map<String, dynamic> data = message.toJson();
      data['model'] = model;

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

      String buffer = '';
      
      final subscription = stream.listen(
        (Uint8List chunk) {
          // Decode binary data ke string UTF-8
          final text = utf8.decode(chunk);
          buffer += text;

          // Proses buffer per baris (Server-Sent Events dipisahkan dengan double newline)
          while (buffer.contains('\n')) {
            final index = buffer.indexOf('\n');
            final line = buffer.substring(0, index).trim();
            buffer = buffer.substring(index + 1);

            if (line.isEmpty) continue;

            // Jika baris berisi [DONE], matikan stream
            if (line == 'data: [DONE]') {
              controller.close();
              return;
            }

            // Jika baris dimulai dengan data:
            if (line.startsWith('data:')) {
              final jsonStr = line.substring(5).trim();
              if (jsonStr.startsWith('[ERROR]')) {
                controller.addError(FormatException(jsonStr));
                return;
              }

              try {
                final Map<String, dynamic> dataMap = jsonDecode(jsonStr);
                final choices = dataMap['choices'] as List?;
                if (choices != null && choices.isNotEmpty) {
                  final delta = choices[0]['delta'] as Map?;
                  final content = delta?['content'] as String?;
                  if (content != null && content.isNotEmpty) {
                    controller.add(content);
                  }
                }
              } catch (_) {
                // Abaikan kesalahan parse JSON untuk baris kosong atau keep-alive comments
              }
            }
          }
        },
        onError: (error) {
          controller.addError(error);
          controller.close();
        },
        onDone: () {
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
