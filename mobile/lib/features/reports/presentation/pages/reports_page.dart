import 'dart:io';
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

  const ReportsPage({super.key, this.onClose});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Real Camera variables
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isGridOn = true;

  // Scanner/UI States
  String _scanStatus = 'MEMUAT KAMERA...';
  double _scanAccuracy = 0.0;
  bool _isCaptured = false;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch reports history on start
    context.read<ReportsBloc>().add(FetchReportsRequested());
    
    // Initialize Camera Feed
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
        _scanStatus = 'MENCARI SASARAN...';
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
            });
            _startScanningSimulation();
          }
        } else {
          setState(() {
            _scanStatus = 'KAMERA TIDAK DITEMUKAN';
          });
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
        setState(() {
          _scanStatus = 'GAGAL MENYALAKAN KAMERA';
        });
      }
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
        _scanStatus = 'IZIN KAMERA DITOLAK';
      });
    }
  }

  void _startScanningSimulation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _isCaptured) return;
    setState(() {
      _scanStatus = 'SASARAN TERDETEKSI: Tumpukan Sampah';
      _scanAccuracy = 92.4;
    });
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
    if (_cameraController == null || !_isCameraInitialized) {
      // Fallback to mock capture if camera package fails (e.g. Emulator)
      _captureMockPhoto();
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      if (!mounted) return;
      setState(() {
        _isCaptured = true;
        _capturedImagePath = file.path;
      });
      context.showSuccessSnackBar('📸 Foto terambil! Analisis dengan AI Scan atau Kirim Laporan.');
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _captureMockPhoto();
    }
  }

  void _captureMockPhoto() {
    setState(() {
      _isCaptured = true;
      _capturedImagePath = 'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&q=80&w=1000';
    });
    context.showSuccessSnackBar('📸 Foto simulator terambil!');
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

    // Show loading spinner dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      ),
    );

    final position = await _getCurrentLocation();
    if (!mounted) return;
    Navigator.pop(context); // Close loading spinner

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
        return _AIScanBottomSheet(imagePath: _capturedImagePath!);
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
            _scanStatus = 'MENCARI SASARAN...';
            _scanAccuracy = 0.0;
          });
          _initializeCamera(); // Re-initialize camera feed
          
          // Refresh list & switch tab
          context.read<ReportsBloc>().add(FetchReportsRequested());
          _tabController.animateTo(1);

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Laporan Terkirim! 🎉',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Laporan Anda berhasil diajukan dan sedang diproses. Anda mendapatkan bonus +50 XP!',
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
                    : const Center(
                        child: CircularProgressIndicator(color: AppColors.emerald),
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
                  color: _scanAccuracy > 0
                      ? AppColors.emerald.withValues(alpha: 0.8)
                      : AppColors.gold.withValues(alpha: 0.5),
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
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing12,
                            vertical: AppConstants.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _scanStatus,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _scanAccuracy > 0
                                  ? AppColors.emeraldLight
                                  : AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_scanAccuracy > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'AKURASI DETEKSI: $_scanAccuracy%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.emerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
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
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.divider, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            setState(() {
                              _isCaptured = false;
                              _capturedImagePath = null;
                            });
                          },
                          child: Text(
                            'Foto Ulang',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // AI Scan
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _openAIScanBottomSheet,
                          icon: const Icon(Icons.insights_rounded, size: 18),
                          label: const Text('AI Scan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Submit
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _submitReport,
                          child: const Text('Kirim Lapor', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
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
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return _buildShimmerLoader();
        } else if (state is ReportsFetchSuccess) {
          final reports = state.reports;
          if (reports.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
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
                                    // Status Badge
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
                                  ],
                                ),
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
          return Center(child: GenesisErrorWidget(message: state.message, onRetry: () {
            context.read<ReportsBloc>().add(FetchReportsRequested());
          }));
        }
        return const SizedBox.shrink();
      },
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

  const _AIScanBottomSheet({required this.imagePath});

  @override
  State<_AIScanBottomSheet> createState() => _AIScanBottomSheetState();
}

class _AIScanBottomSheetState extends State<_AIScanBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _simulateInitialAIScan();
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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _simulateInitialAIScan() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _messages.add({
        'sender': 'ai',
        'text': '🔍 **ANALISIS GAMBAR BERHASIL**\n\n'
            '- **Kategori Sampah**: Plastik & Logam Campuran\n'
            '- **Kondisi**: Layak Daur Ulang\n'
            '- **Tingkat Bahaya**: Sangat Rendah\n\n'
            '💡 **Rekomendasi Penanganan Warga**:\n'
            '1. Harap pisahkan botol plastik PET dengan kaleng aluminium.\n'
            '2. Pastikan wadah tidak menampung cairan berbahaya.\n'
            '3. Tekan atau remas botol untuk menghemat volume wadah penampung.\n\n'
            'Kirim laporan ini sekarang untuk mendapatkan bonus **+50 XP** dan koin reward lingkungan!',
      });
      _isTyping = false;
    });
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

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    String responseText = '';
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('poin') || lowerQuery.contains('koin') || lowerQuery.contains('xp')) {
      responseText = 'Setiap laporan tumpukan sampah yang disetujui bernilai +50 XP. Poin koin daur ulang dapat ditukar dengan voucher belanja di menu utama.';
    } else {
      responseText = 'Regulasi kebersihan kota melarang pembuangan sampah anorganik secara bercampur di fasilitas publik. Anda disarankan membawanya ke Bank Sampah terdekat.';
    }

    setState(() {
      _messages.add({'sender': 'ai', 'text': responseText});
      _isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                    const Icon(Icons.insights_rounded, color: AppColors.emerald, size: 22),
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
              physics: const BouncingScrollPhysics(),
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
                    child: Text(
                      msg['text']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
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
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 10.0
                  : 20.0,
            ),
            child: Row(
              children: [
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
          children: List.generate(3, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeInOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navy600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
