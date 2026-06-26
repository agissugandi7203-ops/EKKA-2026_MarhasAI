import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

  String _selectedModel = 'google/gemini-2.5-flash';
  String? _attachedFilePath;
  bool _isTyping = false;
  bool _isVoiceRecording = false;
  bool _isTranscribing = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  String _lastWords = '';

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
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _orbAnimationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final hasInput = text.isNotEmpty || _attachedFilePath != null;
    if (hasInput != _isTyping) {
      setState(() {
        _isTyping = hasInput;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage([String? customText]) async {
    final query = customText ?? _textController.text.trim();
    if (query.isEmpty && _attachedFilePath == null) return;

    String? imageBase64;
    String? pdfBase64;

    if (_attachedFilePath != null) {
      try {
        final file = File(_attachedFilePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final encoded = base64Encode(bytes);
          if (_attachedFilePath!.endsWith('.pdf')) {
            pdfBase64 = encoded;
          } else {
            imageBase64 = encoded;
          }
        } else {
          // Fallback dummy base64 for simulation if file does not exist
          const dummyBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
          if (_attachedFilePath!.endsWith('.pdf')) {
            pdfBase64 = dummyBase64;
          } else {
            imageBase64 = dummyBase64;
          }
        }
      } catch (e) {
        debugPrint('Error reading attached file: $e');
      }
    }

    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      message: query.isEmpty ? 'Mengirim lampiran berkas.' : query,
      imageBase64: imageBase64,
      pdfBase64: pdfBase64,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      context.read<ChatBloc>().add(SendMessageRequested(userMsg, _selectedModel));
      
      // Trigger daily quest challenge completion
      DioClient.completeChallenge('chat_ai');

      setState(() {
        _attachedFilePath = null;
        _isTyping = false;
      });

      if (customText == null) {
        _textController.clear();
      }
      
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          context.showErrorSnackBar(state.errorMessage!);
        }
        _scrollToBottom();
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
                    backgroundColor: AppColors.navy900,
                    child: Text('🤖', style: TextStyle(fontSize: 13)),
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
                  onPressed: () {
                    context.read<ChatBloc>().add(ClearChatRequested());
                  },
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
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppConstants.pagePaddingH),
                          itemCount: messages.length + (_isTranscribing ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length && _isTranscribing) {
                              return _buildTranscribingIndicator();
                            }
                            final msg = messages[index];
                            final isActiveStreaming = isStreaming &&
                                (index == messages.length - 1) &&
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
                 width: 160,
                 height: 160,
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
    final activeModel = _selectedModel;
    String modelName = 'Geni-Flash';
    Color badgeColor = const Color(0xFF8B5CF6); // Lavender/purple
    if (activeModel.contains('pro')) {
      modelName = 'Geni-Pro';
      badgeColor = const Color(0xFF10B981); // Emerald/Green
    } else if (activeModel.contains('deepseek')) {
      modelName = 'DeepSeek-Chat';
      badgeColor = const Color(0xFF06B6D4); // Cyan
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
                backgroundColor: AppColors.navy900,
                child: Text('🤖', style: TextStyle(fontSize: 12)),
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
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, color: AppColors.textSecondary, size: 16),
                tooltip: 'Salin Pesan',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: msg.message));
                  context.showSuccessSnackBar('Pesan berhasil disalin ke papan klip!');
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        // AI Body Content: Clean full-width text without any background, rendered with Markdown Parser
        Padding(
          padding: const EdgeInsets.only(left: 36.0, right: 8.0, bottom: 12.0),
          child: msg.message.isEmpty
              ? SizedBox(
                  width: 50,
                  height: 30,
                  child: Lottie.asset(
                    'assets/animations/global/ai_thinking.json',
                    fit: BoxFit.contain,
                  ),
                )
              : _MarkdownStreamRenderer(
                  data: msg.message,
                  isStreaming: isActiveStreaming,
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
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: source, imageQuality: 80);
      if (img != null) {
        setState(() {
          _attachedFilePath = img.path;
        });
        _onTextChanged();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        context.showErrorSnackBar('Gagal mengambil gambar: $e');
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() {
            _attachedFilePath = path;
          });
          _onTextChanged();
        }
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      if (mounted) {
        context.showErrorSnackBar('Gagal memilih file PDF: $e');
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
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
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
                            _buildSheetModelItem('google/gemini-2.5-flash', '⚡ Flash', setSheetState),
                            _buildSheetModelItem('google/gemini-2.5-pro', '💎 Pro', setSheetState),
                            _buildSheetModelItem('deepseek/deepseek-chat', '🤖 DeepSeek', setSheetState),
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
                  color: gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
    final isPdf = _attachedFilePath!.endsWith('.pdf');
    final filename = _attachedFilePath!.split('/').last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: isPdf ? Colors.red : AppColors.emerald,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              filename,
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
                _attachedFilePath = null;
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

  Widget _buildNormalInputComposer(bool isStreaming) {
    return Row(
      children: [
        // Plus/Attachment button
        GestureDetector(
          onTap: _showAttachmentMenu,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.navy700,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Expanded text input composer
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy900.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Attachment preview inside the box (above text input field)
                      if (_attachedFilePath != null) ...[
                        _buildAttachmentPreviewInline(),
                        const SizedBox(height: 6),
                      ],
                      
                      // Text input row
                      Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy900),
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 5,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: isStreaming ? 'Geni sedang mengetik...' : 'Tanya Geni sesuatu...',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Merged Send/Mic button on the right
        GestureDetector(
          onTap: isStreaming ? null : (_isTyping ? () => _sendMessage() : _startVoiceInput),
          child: AnimatedScale(
            scale: isStreaming ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isStreaming
                      ? [AppColors.disabled, AppColors.disabled]
                      : [
                          const Color(0xFF0F2042),
                          const Color(0xFF0A1628),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F2042).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _isTyping ? Icons.send_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkdownStreamRenderer extends StatefulWidget {
  final String data;
  final bool isStreaming;

  const _MarkdownStreamRenderer({
    required this.data,
    required this.isStreaming,
  });

  @override
  State<_MarkdownStreamRenderer> createState() => _MarkdownStreamRendererState();
}

class _MarkdownStreamRendererState extends State<_MarkdownStreamRenderer> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _showCursor = !_showCursor;
            });
            _blinkController.forward(from: 0.0);
          }
        }
      });
    if (widget.isStreaming) {
      _blinkController.forward();
    }
  }

  @override
  void didUpdateWidget(_MarkdownStreamRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !_blinkController.isAnimating) {
      _blinkController.forward();
    } else if (!widget.isStreaming && _blinkController.isAnimating) {
      _blinkController.stop();
      if (mounted) {
        setState(() {
          _showCursor = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.isStreaming && _showCursor ? '${widget.data} █' : widget.data;

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
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
        ),
        listBullet: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.navy600,
          fontWeight: FontWeight.bold,
        ),
        tableBorder: TableBorder.all(
          color: AppColors.divider,
          width: 1,
        ),
        tableHead: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.navy900,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        tableBody: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
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
