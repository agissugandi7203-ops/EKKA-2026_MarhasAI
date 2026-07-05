import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/error_handler.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/models/chat_message_model.dart';

// ── EVENTS ──
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistoryRequested extends ChatEvent {}

class SendMessageRequested extends ChatEvent {
  final ChatMessageModel message;
  final String model;
  final bool webSearch;

  const SendMessageRequested(this.message, this.model, {this.webSearch = false});

  @override
  List<Object?> get props => [message, model, webSearch];
}

class ClearChatRequested extends ChatEvent {}

class CancelStreamRequested extends ChatEvent {}

// Event internal untuk update chunk teks stream
class _StreamChunkReceived extends ChatEvent {
  final String chunk;

  const _StreamChunkReceived(this.chunk);

  @override
  List<Object?> get props => [chunk];
}

class _StreamCompleted extends ChatEvent {}

class _StreamFailed extends ChatEvent {
  final String error;

  const _StreamFailed(this.error);

  @override
  List<Object?> get props => [error];
}


// ── STATES ──
class ChatState extends Equatable {
  final List<ChatMessageModel> messages;
  final bool isStreaming;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isStreaming,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: errorMessage, // Reset error jika di-set ke null otomatis lewat copy
    );
  }

  @override
  List<Object?> get props => [messages, isStreaming, errorMessage];
}


// ── BLOC ──
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRemoteDataSource _chatRemoteDataSource;
  StreamSubscription<String>? _streamSubscription;

  ChatBloc(this._chatRemoteDataSource) : super(const ChatState()) {
    on<LoadChatHistoryRequested>(_onLoadChatHistoryRequested);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<ClearChatRequested>(_onClearChatRequested);
    on<CancelStreamRequested>(_onCancelStreamRequested);
    on<_StreamChunkReceived>(_onStreamChunkReceived);
    on<_StreamCompleted>(_onStreamCompleted);
    on<_StreamFailed>(_onStreamFailed);

    add(LoadChatHistoryRequested());
  }

  Future<void> _onLoadChatHistoryRequested(
    LoadChatHistoryRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString('chat_history');
      if (historyStr != null && historyStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(historyStr) as List<dynamic>;
        final messages = decoded
            .map((item) => ChatMessageModel.fromLocalJson(item as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(messages: messages));
      } else {
        emit(const ChatState());
      }
    } catch (e) {
      emit(const ChatState());
    }
  }

  Future<void> _saveChatHistory(List<ChatMessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (messages.isEmpty) {
        await prefs.remove('chat_history');
      } else {
        final encoded = jsonEncode(messages.map((msg) => msg.toLocalJson()).toList());
        await prefs.setString('chat_history', encoded);
      }
    } catch (e) {
      // safe catch
    }
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    // Extract history (previous messages in conversation) before updating
    final history = List<ChatMessageModel>.from(state.messages);

    // 1. Tambahkan pesan user ke daftar chat dan set status isStreaming ke true
    final updatedMessages = List<ChatMessageModel>.from(state.messages)..add(event.message);
    
    // Inisialisasi bubble pesan bot kosong yang nanti akan diisi oleh chunk stream
    final botMessagePlaceholder = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'bot',
      message: '',
      model: event.model,
      timestamp: DateTime.now(),
    );
    updatedMessages.add(botMessagePlaceholder);

    emit(state.copyWith(
      messages: updatedMessages,
      isStreaming: true,
      errorMessage: null,
    ));

    // 2. Batalkan subscription lama jika ada
    await _streamSubscription?.cancel();

    // 3. Mulai request stream ke backend
    _streamSubscription = _chatRemoteDataSource.sendMessageStream(event.message, event.model, history, webSearch: event.webSearch).listen(
      (chunk) {
        add(_StreamChunkReceived(chunk));
      },
      onError: (err) {
        final appError = ErrorHandler.handle(err);
        add(_StreamFailed(appError.message));
      },
      onDone: () {
        add(_StreamCompleted());
      },
      cancelOnError: true,
    );
  }

  void _onStreamChunkReceived(
    _StreamChunkReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state.messages.isEmpty) return;

    final updatedMessages = List<ChatMessageModel>.from(state.messages);
    
    // Cari index pesan bot terakhir (yang sedang aktif di-stream)
    final lastBotIndex = updatedMessages.lastIndexWhere((msg) => msg.sender == 'bot');
    
    if (lastBotIndex != -1) {
      final activeBotMessage = updatedMessages[lastBotIndex];
      // Akumulasikan teks chunk ke dalam pesan bot
      updatedMessages[lastBotIndex] = activeBotMessage.copyWith(
        message: activeBotMessage.message + event.chunk,
      );

      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void _onStreamCompleted(
    _StreamCompleted event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isStreaming: false));
    _saveChatHistory(state.messages);
  }

  void _onStreamFailed(
    _StreamFailed event,
    Emitter<ChatState> emit,
  ) {
    final updatedMessages = List<ChatMessageModel>.from(state.messages);
    if (updatedMessages.isNotEmpty) {
      final lastMsg = updatedMessages.last;
      if (lastMsg.sender == 'bot' && lastMsg.message.isEmpty) {
        updatedMessages[updatedMessages.length - 1] = lastMsg.copyWith(
          message: 'Maaf Kak, sistem kami sedang mengalami gangguan koneksi. Silakan coba beberapa saat lagi.',
        );
      }
    }
    emit(state.copyWith(
      messages: updatedMessages,
      isStreaming: false,
      errorMessage: event.error,
    ));
    _saveChatHistory(updatedMessages);
  }

  void _onClearChatRequested(
    ClearChatRequested event,
    Emitter<ChatState> emit,
  ) {
    _streamSubscription?.cancel();
    emit(const ChatState());
    _saveChatHistory([]);
  }

  Future<void> _onCancelStreamRequested(
    CancelStreamRequested event,
    Emitter<ChatState> emit,
  ) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    if (state.messages.isNotEmpty) {
      final lastMsg = state.messages.last;
      if (lastMsg.sender == 'bot' && lastMsg.message.isEmpty) {
        // Hapus placeholder kosong jika baru mulai stream lalu dibatalkan
        final updatedMessages = List<ChatMessageModel>.from(state.messages)..removeLast();
        emit(state.copyWith(
          messages: updatedMessages,
          isStreaming: false,
        ));
        _saveChatHistory(updatedMessages);
        return;
      }
    }

    emit(state.copyWith(isStreaming: false));
    _saveChatHistory(state.messages);
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
