import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/voice_waveform_indicator.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final VoidCallback? onClose;

  const ChatPage({
    super.key,
    this.onClose,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _orbAnimationController;
  late Animation<double> _orbScaleAnimation;

  String _selectedModel = 'google/gemini-3.5-flash';
  final Set<String> _expandedThoughtMessages = {};
  String? _attachedFileName;
  Uint8List? _attachedFileBytes;
  bool _isTyping = false;
  bool _isVoiceRecording = false;
  bool _isTranscribing = false;
  bool _webSearchEnabled = false;
  bool _previousIsStreaming = false;
  OverlayEntry? _topToastOverlayEntry;

  final AudioRecorder _audioRecorder = AudioRecorder();
  String _lastWords = '';
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  bool _wasMulti = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    
    // Animation controller for the breathing glowing orb
    _orbAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _orbScaleAnimation = Tween<double>(begin: 0.95, end: 1.04).animate(
      CurvedAnimation(parent: _orbAnimationController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _topToastOverlayEntry?.remove();
    _topToastOverlayEntry = null;
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _orbAnimationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final hasInput = text.isNotEmpty || _attachedFileBytes != null;
    
    final isMulti = _textController.text.contains('\n') || _textController.text.length > 40;
    if (isMulti != _wasMulti) {
      _wasMulti = isMulti;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    }

    setState(() {
      _isTyping = hasInput;
    });
  }
  void _scrollToBottom({bool force = false, bool isStreaming = false}) {
    if (_scrollController.hasClients) {
      // With reverse: true, the bottom of the list is at offset 0.
      final double offset = _scrollController.offset;

      // Only scroll if forced or user is already near the bottom (within 150px)
      if (force || offset < 150) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          if (isStreaming) {
            _scrollController.jumpTo(0);
          } else {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _sendMessage([String? customText]) async {
    final query = customText ?? _textController.text.trim();
    if (query.isEmpty && _attachedFileBytes == null) return;

    String? imageBase64;
    String? pdfBase64;

    if (_attachedFileBytes != null && _attachedFileName != null) {
      try {
        final encoded = base64Encode(_attachedFileBytes!);
        if (_attachedFileName!.toLowerCase().endsWith('.pdf')) {
          pdfBase64 = encoded;
        } else {
          imageBase64 = encoded;
        }
      } catch (e) {
        debugPrint('Error encoding attached file: $e');
      }
    }

    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      message: query.isEmpty ? 'Mengirim lampiran berkas.' : query,
      imageBase64: imageBase64,
      pdfBase64: pdfBase64,
      model: _selectedModel,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      context.read<ChatBloc>().add(SendMessageRequested(
        userMsg,
        _selectedModel,
        webSearch: _webSearchEnabled,
      ));
      
      // Trigger daily quest challenge completion
      DioClient.completeChallenge('chat_ai');

      setState(() {
        _attachedFileName = null;
        _attachedFileBytes = null;
        _isTyping = false;
      });

      if (customText == null) {
        _textController.clear();
      }
      
      _scrollToBottom(force: true);
    }
  }

  void _showTopToast(String message, {bool isSuccess = true}) {
    _topToastOverlayEntry?.remove();
    _topToastOverlayEntry = null;

    final overlay = Overlay.of(context);
    _topToastOverlayEntry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () {
          _topToastOverlayEntry?.remove();
          _topToastOverlayEntry = null;
        },
      ),
    );

    overlay.insert(_topToastOverlayEntry!);
  }

  List<Map<String, String>> _extractSources(String text) {
    final List<Map<String, String>> sources = [];
    final regExp = RegExp(r'\[([^\]]+)\]\((https?://[^\s)]+)\)');
    final matches = regExp.allMatches(text);
    
    final Set<String> seenUrls = {};
    for (final match in matches) {
      final title = match.group(1)?.trim() ?? '';
      final url = match.group(2)?.trim() ?? '';
      if (url.isNotEmpty && !seenUrls.contains(url)) {
        seenUrls.add(url);
        sources.add({
          'title': title,
          'url': url,
        });
      }
    }
    return sources;
  }

  Widget _buildGroundingSources(String text) {
    final sources = _extractSources(text);
    if (sources.isEmpty) return const SizedBox.shrink();

    const Color burgundyColor = Color(0xFF800020);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.language_rounded,
              size: 14,
              color: burgundyColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Sumber Referensi Terkait:',
              style: AppTextStyles.bodySmall.copyWith(
                color: burgundyColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: sources.map((source) {
              final url = source['url'] ?? '';
              final domain = Uri.tryParse(url)?.host ?? source['title'] ?? 'web';
              final cleanDomain = domain.replaceFirst('www.', '');
              final faviconUrl = 'https://www.google.com/s2/favicons?sz=64&domain=$domain';

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: url,
                  child: InkWell(
                    onTap: () {
                      if (url.isNotEmpty) {
                        _showCitationPreviewSheet(context, url, source['title'] ?? '');
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: burgundyColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: burgundyColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Website Favicon or Fallback Icon
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              faviconUrl,
                              width: 12,
                              height: 12,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.language_rounded,
                                size: 12,
                                color: burgundyColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cleanDomain,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: burgundyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  void _showClearChatConfirmDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                offset: Offset(0, 4),
                blurRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Riwayat Obrolan',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Apakah Anda yakin ingin menghapus seluruh riwayat obrolan dengan Geni AI?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<ChatBloc>().add(ClearChatRequested());
                      },
                      child: Text(
                        'Hapus',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          context.showErrorSnackBar(state.errorMessage!);
        }

        final wasStreaming = _previousIsStreaming;
        _previousIsStreaming = state.isStreaming;

        // Only scroll to bottom (offset 0) when a stream just completed, or when a new user message is sent
        if ((wasStreaming && !state.isStreaming) || (state.messages.isNotEmpty && state.messages.last.sender == 'user')) {
          _scrollToBottom(force: true);
        }
      },
      builder: (context, state) {
        final messages = state.messages;
        final isStreaming = state.isStreaming;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: widget.onClose != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy900, size: 20),
                    onPressed: widget.onClose,
                  )
                : null,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.navy500, AppColors.navy200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Asisten Geni AI',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navy900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              if (messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textSecondary),
                  tooltip: 'Hapus Obrolan',
                  onPressed: _showClearChatConfirmDialog,
                ),
            ],
          ),
          body: Container(
            color: AppColors.surface,
            child: Column(
              children: [
                // ── Chat/Welcome Area ──
                Expanded(
                  child: messages.isEmpty
                      ? _buildWelcomeDashboard()
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppConstants.pagePaddingH),
                          itemCount: messages.length + (_isTranscribing ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isTranscribing && index == 0) {
                              return _buildTranscribingIndicator();
                            }
                            
                            final msgIndex = _isTranscribing ? messages.length - index : messages.length - 1 - index;
                            final msg = messages[msgIndex];
                            
                            final isActiveStreaming = isStreaming &&
                                (msgIndex == messages.length - 1) &&
                                msg.sender == 'bot';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                              child: _buildChatBubble(msg, isActiveStreaming: isActiveStreaming),
                            );
                          },
                        ),
                ),

                // ── Horizontal Starter Prompts (Always floating above input composer when empty) ──
                if (messages.isEmpty)
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 280),
                    child: _buildHorizontalPrompts(),
                  ),

                // ── Input Bar ──
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 320),
                  child: _buildInputComposer(isStreaming),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeDashboard() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
             // Premium AI Home Lottie Animation with breathing effect
             ScaleTransition(
               scale: _orbScaleAnimation,
               child: SizedBox(
                 width: 240,
                 height: 240,
                 child: Lottie.asset(
                   'assets/animations/artificial/ai_home.json',
                   repeat: true,
                 ),
               ),
             ),
            const SizedBox(height: 36),
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 120),
              child: Text(
                'Halo Warga!',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 180),
              child: Text(
                'Ada yang bisa Geni bantu hari ini?',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 240),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tanyakan seputar peraturan lingkungan, denda pembuangan sampah daerah, peringkat wilayah, atau daur ulang sampah terdekat.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 13,
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalPrompts() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildSmallPromptPill(
              '🏆 Cara Naik Level',
              () => _sendMessage('Bagaimana cara cepat menaikkan level?'),
              AppColors.navy500,
            ),
            const SizedBox(width: 10),
            _buildSmallPromptPill(
              '🚮 Denda Sampah',
              () => _sendMessage('Berapa denda membuang sampah sembarangan?'),
              AppColors.navy700,
            ),
            const SizedBox(width: 10),
            _buildSmallPromptPill(
              '♻️ Bank Sampah terdekat',
              () => _sendMessage('Lokasi daur ulang sampah terdekat di Bandung?'),
              AppColors.navy600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPromptPill(String label, VoidCallback onTap, Color themeColor) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy900.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.navy900,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_outward_rounded, color: themeColor, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, {bool isActiveStreaming = false}) {
    final isSender = msg.sender == 'user';

    if (isSender) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 48.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.navy700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              msg.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
        ),
      );
    }

    // Bot/AI Message: ChatGPT style (No bubble wrapper, full width, beautifully parsed Markdown)
    final msgModel = msg.model ?? _selectedModel;
    String modelName = 'Geni-Flash';
    Color badgeColor = const Color(0xFF8B5CF6); // Lavender/purple
    if (msgModel.contains('pro')) {
      modelName = 'Geni-Pro (Thinking)';
      badgeColor = const Color(0xFF10B981); // Emerald/Green
    }

    // Parse thought tags
    String thoughtContent = '';
    String mainContent = msg.message;

    if (msg.message.contains('<thought>')) {
      final parts = msg.message.split('</thought>');
      if (parts.length > 1) {
        thoughtContent = parts[0].replaceAll('<thought>', '').trim();
        mainContent = parts.sublist(1).join('</thought>').trim();
      } else {
        // Thinking is still in progress (only open tag present)
        thoughtContent = msg.message.replaceAll('<thought>', '').trim();
        mainContent = '';
      }
    }

    final collapsedKey = '${msg.id}_collapsed';
    final isExpanded = _expandedThoughtMessages.contains(msg.id) || 
        (isActiveStreaming && !_expandedThoughtMessages.contains(collapsedKey));

    Widget? thoughtPanel;
    if (thoughtContent.isNotEmpty) {
      thoughtPanel = Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Slate 50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0), // Slate 200
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _toggleThoughtExpansion(msg.id, isActiveStreaming),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.navy500,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isActiveStreaming && mainContent.isEmpty
                            ? 'Geni AI sedang berpikir...'
                            : 'Proses Berpikir',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.navy800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thoughtContent,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        fontSize: 12.5,
                      ),
                    ),
                    if (isActiveStreaming && mainContent.isEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Merumuskan jawaban...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Header Row: Avatar, Title, Active Model badge, Copy Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.navy500, AppColors.navy200],
                ),
              ),
              child: const CircleAvatar(
                radius: 13,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Asisten Geni AI',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.navy900,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            // Dynamic Model Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Text(
                modelName,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            // Copy button
            if (msg.message.isNotEmpty)
              _CopyButton(message: msg.message),
          ],
        ),
        const SizedBox(height: 10),
        // AI Body Content: Clean full-width text without any background, rendered with Markdown Parser
        Padding(
          padding: const EdgeInsets.only(left: 36.0, right: 8.0, bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: (mainContent.isEmpty && thoughtContent.isEmpty)
                    ? SizedBox(
                        key: const ValueKey('thinking'),
                        child: _webSearchEnabled
                            ? const _WebSearchGroundingIndicator()
                            : const _ThinkingIndicator(),
                      )
                    : Column(
                        key: const ValueKey('content'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (thoughtPanel != null) thoughtPanel,
                          if (mainContent.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: _MarkdownStreamRenderer(
                                data: mainContent,
                                isStreaming: isActiveStreaming,
                              ),
                            ),
                        ],
                      ),
              ),
              _buildGroundingSources(msg.message),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 36.0, right: 8.0),
          child: Divider(color: AppColors.divider, height: 24, thickness: 1),
        ),
      ],
    );
  }


  Widget _buildTranscribingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.navy100,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Lottie.asset(
                  'assets/animations/global/global_loading.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Mentranskripsi rekaman suara...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_attachedFileBytes != null) {
      context.showErrorSnackBar('Hanya dapat mengunggah 1 berkas lampiran saja. Silakan hapus lampiran sebelumnya terlebih dahulu.');
      return;
    }
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: source, imageQuality: 80);
      if (img != null) {
        final bytes = await img.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Berkas gambar kosong / gagal dimuat.');
        }
        final double sizeInMb = bytes.lengthInBytes / (1024 * 1024);
        if (sizeInMb > 10.0) {
          throw Exception('Ukuran berkas melebihi batas maksimal 10MB (Ukuran file: ${sizeInMb.toStringAsFixed(2)}MB).');
        }
        setState(() {
          _attachedFileName = img.name;
          _attachedFileBytes = bytes;
        });
        _onTextChanged();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        context.showErrorSnackBar('Gagal mengambil gambar: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  Future<void> _pickPDF() async {
    if (_attachedFileBytes != null) {
      context.showErrorSnackBar('Hanya dapat mengunggah 1 berkas lampiran saja. Silakan hapus lampiran sebelumnya terlebih dahulu.');
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        final file = result.files.single;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null && !kIsWeb) {
          bytes = File(file.path!).readAsBytesSync();
        }
        if (bytes == null || bytes.isEmpty) {
          throw Exception('Berkas PDF kosong / gagal dimuat.');
        }
        final double sizeInMb = bytes.lengthInBytes / (1024 * 1024);
        if (sizeInMb > 10.0) {
          throw Exception('Ukuran berkas melebihi batas maksimal 10MB (Ukuran file: ${sizeInMb.toStringAsFixed(2)}MB).');
        }
        setState(() {
          _attachedFileName = file.name;
          _attachedFileBytes = bytes;
        });
        _onTextChanged();
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      if (mounted) {
        context.showErrorSnackBar('Gagal memilih file PDF: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  void _startVoiceInput() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/temp_record.m4a';
        
        setState(() {
          _isVoiceRecording = true;
          _lastWords = 'Merekam suara...';
        });

        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
      } else {
        if (mounted) {
          context.showErrorSnackBar('Izin mikrofon ditolak.');
        }
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
      if (mounted) {
        context.showErrorSnackBar('Gagal memulai perekaman suara: $e');
      }
    }
  }

  void _stopVoiceInput({bool send = false}) async {
    if (_isVoiceRecording) {
      try {
        final chatRemoteDataSource = context.read<ChatRemoteDataSource>();
        final path = await _audioRecorder.stop();
        setState(() {
          _isVoiceRecording = false;
        });

        if (path != null) {
          setState(() {
            _isTranscribing = true;
          });

          final file = File(path);
          final bytes = await file.readAsBytes();
          final base64Audio = base64Encode(bytes);

          final transcribedText = await chatRemoteDataSource.transcribeAudio(base64Audio, 'm4a');

          if (!mounted) return;
          setState(() {
            _isTranscribing = false;
            _textController.text = transcribedText;
          });
          _onTextChanged();

          if (send && transcribedText.isNotEmpty) {
            _sendMessage();
          }
        }
      } catch (e) {
        debugPrint('Error transcribing audio: $e');
        if (mounted) {
          setState(() {
            _isTranscribing = false;
          });
          context.showErrorSnackBar('Gagal mentranskripsi audio: $e');
        }
      }
    }
  }

  void _cancelVoiceInput() async {
    if (_isVoiceRecording) {
      await _audioRecorder.stop();
      setState(() {
        _isVoiceRecording = false;
        _lastWords = '';
      });
    }
  }

  void _toggleThoughtExpansion(String msgId, bool isActiveStreaming) {
    setState(() {
      final collapsedKey = '${msgId}_collapsed';
      if (_expandedThoughtMessages.contains(msgId) || 
          (isActiveStreaming && !_expandedThoughtMessages.contains(collapsedKey))) {
        _expandedThoughtMessages.remove(msgId);
        _expandedThoughtMessages.add(collapsedKey);
      } else {
        _expandedThoughtMessages.add(msgId);
        _expandedThoughtMessages.remove(collapsedKey);
      }
    });
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE2E8F0),
                      offset: Offset(0, -4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PILIH MODEL AI',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.navy900,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.navy50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildSheetModelItem('google/gemini-3.5-flash', '⚡ Geni Flash (3.5)', setSheetState),
                            _buildSheetModelItem('google/gemini-3.1-pro-preview', '🧠 Geni Pro (Thinking)', setSheetState),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'LAMPIRKAN BERKAS',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.navy900,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAttachmentGridItem(
                            icon: Icons.image_rounded,
                            label: 'Galeri Foto',
                            gradientColors: [AppColors.emerald, const Color(0xFF34D399)],
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          _buildAttachmentGridItem(
                            icon: Icons.camera_alt_rounded,
                            label: 'Kamera',
                            gradientColors: [AppColors.gold, const Color(0xFFFBBF24)],
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          _buildAttachmentGridItem(
                            icon: Icons.picture_as_pdf_rounded,
                            label: 'Berkas PDF',
                            gradientColors: [AppColors.burgundy500, const Color(0xFFF87171)],
                            onTap: () {
                              Navigator.pop(context);
                              _pickPDF();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetModelItem(String modelId, String label, StateSetter setSheetState) {
    final isSelected = _selectedModel == modelId;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedModel = modelId;
          });
          setSheetState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy700 : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentGridItem({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy900,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildAttachmentPreviewInline() {
    if (_attachedFileName == null || _attachedFileBytes == null) return const SizedBox.shrink();

    final isPdf = _attachedFileName!.toLowerCase().endsWith('.pdf');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPdf)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.memory(
                  _attachedFileBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _attachedFileName!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _attachedFileName = null;
                _attachedFileBytes = null;
              });
              _onTextChanged();
            },
            child: const Icon(Icons.cancel_rounded, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildInputComposer(bool isStreaming) {
    if (_isTranscribing) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 8.0
              : 18.0,
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2042)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Memproses & mentranskripsi suara...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF0F2042),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 8.0
            : 18.0,
      ),
      child: _isVoiceRecording
          ? _buildVoiceRecordingComposer()
          : _buildNormalInputComposer(isStreaming),
    );
  }

  Widget _buildVoiceRecordingComposer() {
    return Row(
      children: [
        GestureDetector(
          onTap: _cancelVoiceInput,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_rounded, color: AppColors.navy600, size: 16),
                const SizedBox(width: 8),
                const VoiceWaveformIndicator(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lastWords.isEmpty ? 'Mendengarkan...' : _lastWords,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _stopVoiceInput(send: false),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendMicButton(bool isStreaming) {
    final isStopButton = isStreaming;

    return GestureDetector(
      onTap: () {
        if (isStopButton) {
          context.read<ChatBloc>().add(CancelStreamRequested());
          _showTopToast('Respons dihentikan oleh pengguna.', isSuccess: false);
        } else {
          if (_isTyping) {
            _sendMessage();
          } else {
            _startVoiceInput();
          }
        }
      },
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isStopButton
                  ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                  : [
                      const Color(0xFF0F2042),
                      const Color(0xFF0A1628),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isStopButton ? AppColors.error.withValues(alpha: 0.3) : const Color(0xFF0A1628),
                offset: const Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(
            isStopButton 
                ? Icons.stop_rounded 
                : (_isTyping ? Icons.send_rounded : Icons.mic_none_rounded),
            color: Colors.white,
            size: isStopButton ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalInputComposer(bool isStreaming) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE2E8F0),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Attachment preview (above input row)
            if (_attachedFileBytes != null) ...[
              _buildAttachmentPreviewInline(),
              const SizedBox(height: 6),
            ],
            
            // 2. Main Input Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Plus/Attachment button
                GestureDetector(
                  onTap: isStreaming ? null : _showAttachmentMenu,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Icon(
                      Icons.add_rounded,
                      color: isStreaming ? AppColors.textDisabled : AppColors.navy700,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Text input field (flexible width, auto-expands from 1 to 5 lines)
                Expanded(
                  child: TextField(
                    key: _textFieldKey,
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: !isStreaming,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isStreaming ? AppColors.textDisabled : AppColors.navy900,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: isStreaming ? 'Geni sedang mengetik...' : 'Tanya Geni sesuatu...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Web Search (Globe icon)
                Tooltip(
                  message: _webSearchEnabled ? 'Pencarian Web Aktif' : 'Pencarian Web Nonaktif',
                  child: InkWell(
                    onTap: isStreaming ? null : () {
                      setState(() {
                        _webSearchEnabled = !_webSearchEnabled;
                      });
                      if (_webSearchEnabled) {
                        _showTopToast(
                          'Pencarian Web Diaktifkan!',
                          isSuccess: true,
                        );
                      } else {
                        _showTopToast(
                          'Pencarian Web Dinonaktifkan.',
                          isSuccess: false,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _webSearchEnabled 
                            ? (isStreaming ? AppColors.disabled : AppColors.gold).withValues(alpha: 0.15) 
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        turns: _webSearchEnabled ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutBack,
                        child: Icon(
                          Icons.language_rounded,
                          color: isStreaming
                              ? AppColors.textDisabled
                              : (_webSearchEnabled ? AppColors.gold : AppColors.textSecondary),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Send/Mic Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _buildSendMicButton(isStreaming),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatefulWidget {
  const _ThinkingIndicator();

  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator> {
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusText = 'Geni sedang bersiap...';
    if (_seconds >= 0 && _seconds < 4) {
      statusText = 'Menghubungkan ke Geni...';
    } else if (_seconds >= 4 && _seconds < 9) {
      statusText = 'Sedang berpikir...';
    } else if (_seconds >= 9 && _seconds < 15) {
      statusText = 'Sebentar lagi...';
    } else {
      statusText = 'Geni sedang merangkum jawaban terbaik...';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Lottie.asset(
            'assets/animations/global/ai_thinking.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            statusText,
            key: ValueKey(statusText),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkdownStreamRenderer extends StatelessWidget {
  final String data;
  final bool isStreaming;

  const _MarkdownStreamRenderer({
    required this.data,
    required this.isStreaming,
  });

  @override
  Widget build(BuildContext context) {
    final text = isStreaming ? '$data █' : data;

    return MarkdownBody(
      data: text,
      selectable: true,
      builders: {
        'pre': DraftMarkdownBuilder(),
        'img': PremiumImageMarkdownBuilder(),
      },
      onTapLink: (text, href, title) {
        if (href != null) {
          _showCitationPreviewSheet(context, href, text);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.navy900,
          height: 1.55,
        ),
        h1: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        h2: AppTextStyles.titleLarge.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        h3: AppTextStyles.titleMedium.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
          height: 1.4,
          fontSize: 15,
        ),
        listBullet: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
        ),
        tableBorder: TableBorder.all(
          color: AppColors.divider,
          width: 1,
        ),
        tableHead: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tableBody: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        code: AppTextStyles.bodySmall.copyWith(
          color: AppColors.burgundy500,
          backgroundColor: AppColors.burgundy50,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: AppColors.navy50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
      ),
    );
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isSuccess ? AppColors.emerald : AppColors.navy700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isSuccess ? AppColors.emerald : AppColors.navy900)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSuccess ? Icons.search_rounded : Icons.language_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebSearchGroundingIndicator extends StatefulWidget {
  const _WebSearchGroundingIndicator();

  @override
  State<_WebSearchGroundingIndicator> createState() => _WebSearchGroundingIndicatorState();
}

class _WebSearchGroundingIndicatorState extends State<_WebSearchGroundingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _currentTextIndex = 0;
  final List<String> _loadingTexts = [
    'Menghubungkan ke layanan pencarian...',
    'Menganalisis kata kunci pencarian warga...',
    'Menelusuri artikel regulasi & berita terpercaya...',
    'Mengekstrak referensi web paling valid...',
    'Menyusun jawaban berbasis data real-time...',
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
    _rotateText();
  }

  void _rotateText() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spin/Scale transition for a tiny globe icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: const Icon(
                Icons.language_rounded,
                color: Color(0xFFD97706),
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 1.0,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
            ),
          ),
          const SizedBox(width: 8),
          // Elegant minimal loading text
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _loadingTexts[_currentTextIndex],
                key: ValueKey<int>(_currentTextIndex),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── UTILITY: SHOW CITATION PREVIEW SHEET ──
void _showCitationPreviewSheet(BuildContext context, String url, String title) {
  final domain = Uri.tryParse(url)?.host ?? title;
  final cleanDomain = domain.replaceFirst('www.', '');

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2042).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.network(
                      'https://www.google.com/s2/favicons?sz=64&domain=$domain',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF0F2042),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'Rujukan Web',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.navy900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cleanDomain,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Tautan referensi luar yang disediakan oleh asisten AI untuk memverifikasi informasi.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan berhasil disalin!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Salin Link',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      String finalUrl = url.trim();
                      if (finalUrl.startsWith('gs://')) {
                        finalUrl = finalUrl.replaceFirst('gs://', 'https://storage.googleapis.com/');
                      } else if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
                        finalUrl = 'https://$finalUrl';
                      }
                      final uri = Uri.tryParse(finalUrl);
                      if (uri != null) {
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          try {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          } catch (e) {
                            debugPrint('Error launching URL: $e');
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2042),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Kunjungi Situs',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      );
    },
  );
}

// ── CUSTOM MARKDOWN ELEMENT BUILDER FOR PREMIUM IMAGE ──
class PremiumImageMarkdownBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'] ?? '';
    if (src.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Image.network(
            src,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: const Color(0xFFF8FAFC),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2042)),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: const Color(0xFFF1F5F9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_rounded, color: AppColors.textDisabled, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat gambar',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
// ── CUSTOM MARKDOWN ELEMENT BUILDER FOR DRAFT CARD ──
class DraftMarkdownBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String language = '';
    
    // Extract language class from children (pre -> code)
    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children![0];
      if (child is md.Element) {
        final className = child.attributes['class'] ?? '';
        if (className.startsWith('language-')) {
          language = className.substring('language-'.length);
        }
      }
    }
    
    // Fallback check on element class
    if (language.isEmpty) {
      final className = element.attributes['class'] ?? '';
      if (className.startsWith('language-')) {
        language = className.substring('language-'.length);
      }
    }

    final content = element.textContent.trim();

    if (language == 'draft') {
      return _DraftCard(textContent: content);
    } else if (language == 'navigation') {
      return _NavigationButtonCard(content: content);
    } else {
      return _CodeBlockCard(
        code: content,
        language: language.isNotEmpty ? language : 'code',
      );
    }
  }
}

// ── DRAFT CARD WIDGET ──
class _DraftCard extends StatefulWidget {
  final String textContent;
  const _DraftCard({required this.textContent});

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
                left: BorderSide(color: Color(0xFF0F2042), width: 4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF0F2042),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Draf Dokumen / Surat',
                  style: TextStyle(
                    color: Color(0xFF0F2042),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: widget.textContent.trim()));
                    setState(() {
                      _isCopied = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _isCopied = false;
                        });
                      }
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _isCopied
                        ? const Row(
                            key: ValueKey('copied'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, color: AppColors.emerald, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Tersalin',
                                style: TextStyle(
                                  color: AppColors.emerald,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            key: ValueKey('copy'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy_all_rounded, color: AppColors.textSecondary, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Salin Draf',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFF0F2042), width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.textContent.trim(),
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                height: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM STATEFUL COPY BUTTON WITH MICRO-INTERACTION ──
class _CopyButton extends StatefulWidget {
  final String message;
  const _CopyButton({required this.message});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isCopied
          ? const SizedBox(
              key: ValueKey('copied'),
              width: 28,
              height: 28,
              child: Icon(
                Icons.check_rounded,
                color: AppColors.emerald,
                size: 15,
              ),
            )
          : SizedBox(
              key: const ValueKey('copy'),
              width: 28,
              height: 28,
              child: IconButton(
                icon: const Icon(
                  Icons.content_copy_rounded,
                  color: AppColors.textSecondary,
                  size: 15,
                ),
                tooltip: 'Salin Pesan',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.message));
                  setState(() {
                    _isCopied = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isCopied = false;
                      });
                    }
                  });
                },
              ),
            ),
    );
  }
}

// ── CUSTOM CODE BLOCK CARD WIDGET ──
class _CodeBlockCard extends StatefulWidget {
  final String code;
  final String language;
  const _CodeBlockCard({required this.code, required this.language});

  @override
  State<_CodeBlockCard> createState() => _CodeBlockCardState();
}

class _CodeBlockCardState extends State<_CodeBlockCard> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.code));
                    setState(() {
                      _copied = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _copied = false;
                        });
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 14,
                        color: _copied ? Colors.green : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _copied ? Colors.green : const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Code Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                widget.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFE2E8F0),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM NAVIGATION BUTTON CARD WIDGET ──
class _NavigationButtonCard extends StatelessWidget {
  final String content;
  const _NavigationButtonCard({required this.content});

  @override
  Widget build(BuildContext context) {
    String label = 'Buka Halaman';
    String route = '';
    String iconStr = 'link';

    final lines = content.split('\n');
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim().toLowerCase();
        final value = parts.sublist(1).join(':').trim();
        if (key == 'label') label = value;
        if (key == 'route') route = value;
        if (key == 'icon') iconStr = value.toLowerCase();
      }
    }

    if (route.isEmpty) return const SizedBox.shrink();

    IconData iconData = Icons.arrow_forward;
    if (iconStr == 'camera') {
      iconData = Icons.camera_alt_outlined;
    } else if (iconStr == 'trophy' || iconStr == 'leaderboard') {
      iconData = Icons.emoji_events_outlined;
    } else if (iconStr == 'gift' || iconStr == 'rewards') {
      iconData = Icons.card_giftcard_outlined;
    } else if (iconStr == 'person' || iconStr == 'profile') {
      iconData = Icons.person_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: AppColors.navy500,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: AppColors.navy500.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            try {
              GoRouter.of(context).push(route);
            } catch (e) {
              debugPrint('GoRouter failed to navigate to $route: $e');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
