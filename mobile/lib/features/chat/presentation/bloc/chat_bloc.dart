import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/error_handler.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/models/chat_message_model.dart';

// ── EVENTS ──
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageRequested extends ChatEvent {
  final ChatMessageModel message;

  const SendMessageRequested(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearChatRequested extends ChatEvent {}

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
    on<SendMessageRequested>(_onSendMessageRequested);
    on<ClearChatRequested>(_onClearChatRequested);
    on<_StreamChunkReceived>(_onStreamChunkReceived);
    on<_StreamCompleted>(_onStreamCompleted);
    on<_StreamFailed>(_onStreamFailed);
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    // 1. Tambahkan pesan user ke daftar chat dan set status isStreaming ke true
    final updatedMessages = List<ChatMessageModel>.from(state.messages)..add(event.message);
    
    // Inisialisasi bubble pesan bot kosong yang nanti akan diisi oleh chunk stream
    final botMessagePlaceholder = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'bot',
      message: '',
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
    _streamSubscription = _chatRemoteDataSource.sendMessageStream(event.message).listen(
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
  }

  void _onStreamFailed(
    _StreamFailed event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isStreaming: false,
      errorMessage: event.error,
    ));
  }

  void _onClearChatRequested(
    ClearChatRequested event,
    Emitter<ChatState> emit,
  ) {
    _streamSubscription?.cancel();
    emit(const ChatState());
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
