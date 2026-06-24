import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/voice_waveform_indicator.dart';
import '../../data/models/chat_message_model.dart';
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
  late AnimationController _orbRotationController;
  late Animation<double> _orbScaleAnimation;

  String _selectedModel = 'google/gemini-2.5-flash';
  String? _attachedFilePath;
  bool _isTyping = false;
  bool _isVoiceRecording = false;

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

    // Animation controller for rotating SweepGradient on the voice orb (GPU-accelerated)
    _orbRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _orbAnimationController.dispose();
    _orbRotationController.dispose();
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
                          itemCount: messages.length + (isStreaming ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length && isStreaming) {
                              return _buildTypingIndicator();
                            }
                            final msg = messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                              child: _buildChatBubble(msg),
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
            // Siri/Gemini voice orb (3D-like glowing breathing gradient sphere)
            RepaintBoundary(
              child: ScaleTransition(
                scale: _orbScaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer soft glow layer (static)
                    Container(
                      width: 155,
                      height: 155,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x44C084FC), // Lavender glow
                            Color(0x22F472B6), // Pink glow
                            Color(0x0038BDF8), // Transparent
                          ],
                          radius: 0.8,
                        ),
                      ),
                    ),
                    // Rotating SweepGradient core
                    RotationTransition(
                      turns: _orbRotationController,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              Color(0xFFC084FC), // Lavender
                              Color(0xFFF472B6), // Pink
                              Color(0xFF38BDF8), // Cyan
                              Color(0xFF818CF8), // Indigo
                              Color(0xFFC084FC), // Lavender wrap
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Inner frosted glass overlay (static reflection highlight)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildChatBubble(ChatMessageModel msg) {
    final isSender = msg.sender == 'user';

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSender) ...[
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
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSender ? AppColors.navy700 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSender ? 20 : 4),
                  bottomRight: Radius.circular(isSender ? 4 : 20),
                ),
                border: isSender
                    ? null
                    : Border.all(color: AppColors.divider.withValues(alpha: 0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy900.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSender ? Colors.white : AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.8), width: 1.2),
              ),
              child: Row(
                children: [
                  _buildPulseDot(0),
                  const SizedBox(width: 4),
                  _buildPulseDot(1),
                  const SizedBox(width: 4),
                  _buildPulseDot(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseDot(int delayIndex) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navy600,
            ),
          ),
        );
      },
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Wrap(
                  children: [
                    // Handle bar
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
                    const SizedBox(height: 24),
                    
                    // Section 1: Model AI
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'PILIH MODEL AI',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _buildModalModelItem(
                      id: 'google/gemini-2.5-flash',
                      title: '⚡ Geni-Flash (Default)',
                      subtitle: 'Cepat & hemat daya untuk aksi sehari-hari',
                      isSelected: _selectedModel == 'google/gemini-2.5-flash',
                      onTap: () {
                        setState(() => _selectedModel = 'google/gemini-2.5-flash');
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    _buildModalModelItem(
                      id: 'google/gemini-2.5-pro',
                      title: '💎 Geni-Pro',
                      subtitle: 'Penalaran kompleks & analisis detail',
                      isSelected: _selectedModel == 'google/gemini-2.5-pro',
                      onTap: () {
                        setState(() => _selectedModel = 'google/gemini-2.5-pro');
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    _buildModalModelItem(
                      id: 'deepseek/deepseek-chat',
                      title: '🤖 DeepSeek-Chat',
                      subtitle: 'Model alternatif bertenaga tinggi',
                      isSelected: _selectedModel == 'deepseek/deepseek-chat',
                      onTap: () {
                        setState(() => _selectedModel = 'deepseek/deepseek-chat');
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    
                    // Section 2: Lampiran
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'LAMPIRKAN MEDIA',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.image_rounded, color: AppColors.navy600),
                      title: Text('Ambil dari Galeri', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _attachedFilePath = 'sampah_plastik.png';
                        });
                        _onTextChanged();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_rounded, color: AppColors.navy600),
                      title: Text('Ambil Foto Kamera', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _attachedFilePath = 'foto_kamera.png';
                        });
                        _onTextChanged();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file_rounded, color: AppColors.navy600),
                      title: Text('Pilih Dokumen/File (PDF)', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _attachedFilePath = 'laporan_bulanan.pdf';
                        });
                        _onTextChanged();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildModalModelItem({
    required String id,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.emerald) : null,
      onTap: onTap,
    );
  }

  Widget _buildAttachmentPreview() {
    final isPdf = _attachedFilePath!.endsWith('.pdf');
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
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
          Text(
            _attachedFilePath!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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

  void _startVoiceInput() {
    setState(() {
      _isVoiceRecording = true;
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attachedFilePath != null) _buildAttachmentPreview(),
          _isVoiceRecording
              ? _buildVoiceRecordingComposer()
              : _buildNormalInputComposer(isStreaming),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingComposer() {
    return Row(
      children: [
        // Cancel recording button
        GestureDetector(
          onTap: () {
            setState(() {
              _isVoiceRecording = false;
            });
          },
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
        // Waveform area
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.divider,
                width: 1.5,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_rounded, color: AppColors.navy600, size: 16),
                SizedBox(width: 8),
                VoiceWaveformIndicator(),
                SizedBox(width: 8),
                Text(
                  'Mendengarkan...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Done recording button
        GestureDetector(
          onTap: () {
            setState(() {
              _isVoiceRecording = false;
              _textController.text = 'Laporkan tumpukan sampah plastik di dekat jalan Diponegoro';
              _isTyping = true;
            });
          },
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
              borderRadius: BorderRadius.circular(32.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
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
