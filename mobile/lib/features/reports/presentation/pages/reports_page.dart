import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ReportsPage extends StatefulWidget {
  final VoidCallback? onClose;
  final bool isActive;

  const ReportsPage({super.key, this.onClose, this.isActive = false});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // Real Camera variables
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isGridOn = true;
  bool _cameraInitializationFailed = false;
  String _cameraErrorMessage = '';

  // Scanner/UI States
  bool _isCaptured = false;
  String? _capturedImagePath;
  final Map<String, List<Map<String, String>>> _aiScanCache = {};

  // Throttle states
  bool _isCapturing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // Fetch reports history on start
    context.read<ReportsBloc>().add(FetchReportsRequested());
    
    // Initialize Camera Feed only if page is active
    if (widget.isActive) {
      _initializeCamera();
    }
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (!_isCaptured) {
          _initializeCamera();
        }
      } else {
        _disposeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isActive && !_isCaptured) {
        _initializeCamera();
      }
    }
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _cameraInitializationFailed = false;
      _cameraErrorMessage = '';
    });

    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });

      try {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _cameraController = CameraController(
            _cameras[0],
            ResolutionPreset.medium,
            enableAudio: false,
          );
          
          await _cameraController!.initialize();
          
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
              _cameraInitializationFailed = false;
            });
          }
        } else {
          debugPrint('Kamera tidak ditemukan');
          if (mounted) {
            setState(() {
              _cameraInitializationFailed = true;
              _cameraErrorMessage = 'Perangkat kamera tidak ditemukan pada sistem.';
            });
          }
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
        if (mounted) {
          setState(() {
            _cameraInitializationFailed = true;
            _cameraErrorMessage = 'Gagal memuat perangkat kamera. Silakan coba lagi.';
          });
        }
      }
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
      });
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _capturePhoto() async {
    if (_isCapturing) return;
    if (_cameraController == null || !_isCameraInitialized) {
      context.showWarningSnackBar('Kamera sedang memuat, silakan tunggu beberapa saat...');
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile file = await _cameraController!.takePicture();
      if (!mounted) return;
      
      // Matikan kamera hardware setelah berhasil capture untuk hemat daya & privasi
      _disposeCamera();

      setState(() {
        _isCaptured = true;
        _capturedImagePath = file.path;
        _isCapturing = false;
      });
      context.showSuccessSnackBar('📸 Foto terambil! Analisis dengan AI Scan atau Kirim Laporan.');
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
      });
      context.showErrorSnackBar('Gagal mengambil foto dari kamera hardware. Silakan coba lagi.');
    }
  }



  Future<Position?> _getCurrentLocation() async {
    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.always || hasPermission == LocationPermission.whileInUse) {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
    return null;
  }

  void _submitReport() async {
    if (_capturedImagePath == null) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final position = await _getCurrentLocation();
    if (!mounted) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final double lat = position?.latitude ?? -6.2088;
    final double lng = position?.longitude ?? 106.8451;

    context.read<ReportsBloc>().add(
      UploadReportRequested(
        imageFile: File(_capturedImagePath!),
        latitude: lat,
        longitude: lng,
        description: 'Laporan sampah terdeteksi oleh kamera warga.',
      ),
    );
  }

  void _openAIScanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AIScanBottomSheet(
          imagePath: _capturedImagePath!,
          initialMessages: _aiScanCache[_capturedImagePath!] ?? [],
          onMessagesUpdated: (msgs) {
            _aiScanCache[_capturedImagePath!] = List<Map<String, String>>.from(msgs);
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'ditolak':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return 'Disetujui';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'pending_ai':
        return 'Analisis AI';
      default:
        return 'Diproses';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportUploadSuccess) {
          // Reset states
          setState(() {
            _isCaptured = false;
            _capturedImagePath = null;
            _isSubmitting = false;
          });
          
          if (widget.isActive) {
            _initializeCamera(); // Re-initialize camera feed only if active
          }

          // Refresh list & switch tab
          context.read<ReportsBloc>().add(FetchReportsRequested());
          _tabController.animateTo(1);

          final isDuplicate = state.response.isDuplicate;

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isDuplicate ? 'Laporan Serupa Ditemukan! 📍' : 'Laporan Terkirim! 🎉',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Text(
                isDuplicate
                    ? 'Laporan serupa telah aktif di lokasi ini dalam 12 jam terakhir. Laporan Anda berhasil digabungkan demi menghindari duplikasi data.'
                    : 'Laporan Anda berhasil diajukan dan sedang diproses oleh AI/Admin untuk verifikasi.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Selesai',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        } else if (state is ReportsFailure) {
          setState(() {
            _isSubmitting = false;
          });
          context.showErrorSnackBar('Gagal mengirim laporan: ${state.message}');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Kamera Scan & Laporan',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.navy500,
            indicatorWeight: 3.0,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Kirim Laporan Baru'),
              Tab(text: 'Riwayat Laporan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // TAB 1: Camera Scanner
            _buildScannerTab(),

            // TAB 2: Report History
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerTab() {
    if (!_isCameraPermissionGranted) {
      return Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_camera_front_rounded, color: AppColors.textDisabled, size: 64),
            const SizedBox(height: 16),
            Text(
              'Izin Kamera Diperlukan',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Genesis memerlukan akses kamera Anda untuk mengambil foto tumpukan sampah dan menganalisisnya secara cerdas.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Buka Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (_cameraInitializationFailed && !_isCaptured) {
      return Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Gagal Membuka Kamera',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _cameraErrorMessage.isNotEmpty 
                  ? _cameraErrorMessage 
                  : 'Terjadi kesalahan sistem saat mencoba mengakses kamera Anda.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _isCaptured
                ? _buildImagePreview(_capturedImagePath!)
                : (_isCameraInitialized && _cameraController != null
                    ? CameraPreview(_cameraController!)
                    : Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Lottie.asset(
                            'assets/animations/global/global_loading.json',
                            fit: BoxFit.contain,
                            frameRate: FrameRate.max,
                          ),
                        ),
                      )),
          ),
        ),

        // Grid lines overlay
        if (_isGridOn && !_isCaptured)
          Positioned.fill(
            child: CustomPaint(
              painter: _CameraGridPainter(),
            ),
          ),

        // HUD Viewfinder
        if (!_isCaptured)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Stack(
                children: [
                  _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                  _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                  _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                  _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Posisikan sampah di dalam bingkai',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Flash & Grid controls
        if (!_isCaptured)
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(
                      _isGridOn ? Icons.grid_on : Icons.grid_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isGridOn = !_isGridOn);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: _isFlashOn ? AppColors.gold : Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ),
              ],
            ),
          ),

        // Captured preview bottom panel (Light Theme)
        if (_isCaptured)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navy50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto Berhasil Diambil',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Deteksi: Tumpukan Sampah Plastik & Logam',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Photo retake
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.divider, width: 1.5),
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _isSubmitting ? null : () {
                              setState(() {
                                _isCaptured = false;
                                _capturedImagePath = null;
                              });
                              _initializeCamera();
                            },
                            icon: const Icon(Icons.replay_rounded, size: 16, color: AppColors.textPrimary),
                            label: Text(
                              'Foto Ulang',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AI Scan
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(23),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFB45309),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _isSubmitting ? null : _openAIScanBottomSheet,
                            icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                            label: const Text(
                              'AI Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Submit
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF34D399), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(23),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF047857),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _isSubmitting ? null : _submitReport,
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Lottie.asset(
                                      'assets/animations/global/global_loading.json',
                                      fit: BoxFit.contain,
                                      frameRate: FrameRate.max,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.send_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Kirim Lapor',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
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

        // Normal capture trigger button
        if (!_isCaptured)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0D5335),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(FetchReportsRequested());
      },
      color: AppColors.navy900,
      backgroundColor: Colors.white,
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return _buildShimmerLoader();
          } else if (state is ReportsFetchSuccess) {
            final reports = state.reports;
            if (reports.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textDisabled),
                      const SizedBox(height: 12),
                      Text(
                        'Belum Ada Riwayat Laporan',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kirim laporan pertamamu untuk melestarikan lingkungan!',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final statusColor = _getStatusColor(report.status);
                final statusLabel = _getStatusLabel(report.status);

                return FadeSlideEntrance(
                  delay: Duration(milliseconds: 50 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          // Thumbnail image
                          _buildThumbnailImage(report.imageUrl),
                          const SizedBox(width: 14),
                          // Text info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.wasteType ?? report.description ?? 'Laporan Lingkungan',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    report.createdAt.length > 10 ? report.createdAt.substring(0, 10) : report.createdAt,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '+50 XP',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.emerald,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Status Badge & Delete option
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 12),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: statusColor,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (report.status.toLowerCase() == 'rejected')
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: AppColors.cardBackground,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                                    title: const Text('Hapus Laporan?', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    content: const Text('Apakah Anda yakin ingin menghapus laporan yang ditolak ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          context.read<ReportsBloc>().add(DeleteReportRequested(report.id));
                                                        },
                                                        child: const Text('Hapus', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.navy50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      width: double.infinity,
                                      child: Text(
                                        'Pesan Admin: ${report.adminNotes}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is ReportsFailure) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: GenesisErrorWidget(message: state.message, onRetry: () {
                  context.read<ReportsBloc>().add(FetchReportsRequested());
                }),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildThumbnailImage(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, err, stack) => Container(
          width: 90,
          height: 90,
          color: AppColors.disabled,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.textDisabled),
        ),
      );
    } else {
      return Image.file(
        File(url),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, err, stack) => Container(
          width: 90,
          height: 90,
          color: AppColors.disabled,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.textDisabled),
        ),
      );
    }
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.emerald, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: AppColors.emerald, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: AppColors.emerald, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: AppColors.emerald, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AIScanBottomSheet extends StatefulWidget {
  final String imagePath;
  final List<Map<String, String>> initialMessages;
  final Function(List<Map<String, String>>) onMessagesUpdated;

  const _AIScanBottomSheet({
    required this.imagePath,
    required this.initialMessages,
    required this.onMessagesUpdated,
  });

  @override
  State<_AIScanBottomSheet> createState() => _AIScanBottomSheetState();
}

class _AIScanBottomSheetState extends State<_AIScanBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _webSearchEnabled = false;
  String _loadingText = 'Geni sedang melihat gambar...';

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages.isNotEmpty) {
      _messages.addAll(widget.initialMessages);
    } else {
      _simulateInitialAIScan();
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }
  }

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          // Hanya scroll otomatis jika pengguna berada di dasar layar chat (selisih < 150px)
          if (maxScroll - currentScroll < 150) {
            _scrollController.animateTo(
              maxScroll,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  void _typewriterEffect(String fullText) async {
    setState(() {
      _isTyping = false;
      _messages.add({
        'sender': 'ai',
        'text': '',
      });
    });

    final int index = _messages.length - 1;
    String displayed = '';
    const delay = Duration(milliseconds: 6);

    for (int i = 0; i < fullText.length; i++) {
      if (!mounted) return;
      displayed += fullText[i];
      setState(() {
        _messages[index]['text'] = displayed;
      });
      _scrollToBottomIfNeeded();
      await Future.delayed(delay);
    }
    widget.onMessagesUpdated(_messages);
  }

  void _simulateInitialAIScan() async {
    setState(() {
      _isTyping = true;
      _loadingText = 'Geni sedang melihat gambar...';
    });

    Timer? loadingTimer;
    int loadingStep = 0;
    final loadingMessages = [
      'Geni sedang melihat gambar...',
      'Sedang menganalisis objek...',
      'Berpikir keras...',
      'Sedikit lagi selesai...',
      'Menyusun kata-kata...',
    ];

    loadingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      loadingStep++;
      if (loadingStep < loadingMessages.length) {
        setState(() {
          _loadingText = loadingMessages[loadingStep];
        });
      }
    });

    try {
      final dio = DioClient().dio;
      final file = File(widget.imagePath);
      final fileName = file.path.split(RegExp(r'[/\\]')).last;
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '/reports/analyze',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      loadingTimer.cancel();

      if (!mounted) return;
      
      final analysisText = response.data['analysis'] as String? ?? 'Gagal menganalisis gambar.';
      _typewriterEffect(analysisText);
    } catch (e) {
      loadingTimer.cancel();
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': '❌ **Gagal melakukan Analisis Gambar via AI Scan**\n\n'
              'Terjadi masalah saat menghubungi server: ${e.toString()}\n\n'
              'Silakan coba kirim ulang atau pastikan koneksi internet Anda stabil.',
        });
        _isTyping = false;
      });
      widget.onMessagesUpdated(_messages);
    }
    _scrollToBottom();
  }

  void _sendMessage() async {
    final query = _chatController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _chatController.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    widget.onMessagesUpdated(_messages);

    // Trigger daily quest challenge completion
    DioClient.completeChallenge('chat_ai');

    try {
      final dio = DioClient().dio;
      // Build history payload from current messages
      final historyPayload = _messages.map((m) => {
        'sender': m['sender'] == 'user' ? 'user' : 'assistant',
        'message': m['text'] ?? '',
      }).toList();

      final response = await dio.post(
        '/chat',
        data: {
          'message': query,
          'history': historyPayload,
          'webSearch': _webSearchEnabled,
        },
      );

      if (!mounted) return;

      final reply = response.data['reply'] as String? ?? 'Geni AI tidak merespons.';
      _typewriterEffect(reply);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': '❌ Gagal mengirim pesan: ${e.toString()}',
        });
        _isTyping = false;
      });
      widget.onMessagesUpdated(_messages);
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.emerald,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Analisis AI Scan',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.navy700 : AppColors.navy50,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: Border.all(
                        color: isUser ? Colors.transparent : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: isUser
                        ? Text(
                            msg['text']!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        : MarkdownBody(
                            data: msg['text']!,
                            selectable: true,
                            builders: {
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
                                fontSize: 15.5,
                                height: 1.55,
                              ),
                              strong: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5,
                                height: 1.55,
                              ),
                              h1: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.4,
                              ),
                              h2: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.5,
                                height: 1.4,
                              ),
                              h3: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                height: 1.4,
                              ),
                              listBullet: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.navy900,
                                fontSize: 15.5,
                                height: 1.55,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // Message Input bar
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: bottomInset > 0
                  ? 10.0
                  : (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom + 10.0
                      : 20.0),
            ),
            child: Row(
              children: [
                // Integrated Web Search button
                Tooltip(
                  message: _webSearchEnabled ? 'Pencarian Web Aktif' : 'Pencarian Web Nonaktif',
                  child: InkWell(
                    onTap: _isTyping ? null : () {
                      setState(() {
                        _webSearchEnabled = !_webSearchEnabled;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _webSearchEnabled 
                            ? (_isTyping ? AppColors.navy100 : AppColors.gold).withValues(alpha: 0.15) 
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        turns: _webSearchEnabled ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutBack,
                        child: Icon(
                          Icons.language_rounded,
                          color: _isTyping
                              ? AppColors.textDisabled
                              : (_webSearchEnabled ? AppColors.gold : AppColors.textSecondary),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.navy50,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _chatController,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan hasil deteksi...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navy800,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navy50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 24,
              child: Lottie.asset(
                'assets/animations/global/ai_thinking.json',
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _loadingText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
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
                      final uri = Uri.tryParse(url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
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

