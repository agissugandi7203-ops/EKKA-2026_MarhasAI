import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class StatisticDetailPage extends StatefulWidget {
  const StatisticDetailPage({super.key});

  @override
  State<StatisticDetailPage> createState() => _StatisticDetailPageState();
}

class _StatisticDetailPageState extends State<StatisticDetailPage> {
  String _selectedPeriod = 'Bulan Ini';
  ProfileModel? _profile;


  String get _fullName => _profile?.fullName ?? 'ARIEF AGIS SUGANDI';
  int get _xp => _profile?.xp ?? 340;
  int get _completedReports => _profile?.reportCount ?? 15;
  int get _totalPoints => _xp * 3;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileRepo = context.read<ProfileRepository>();
      final profile = await profileRepo.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (_) {
      // Fail silently, getters will use defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Light theme page background
      body: Stack(
        children: [
          // ── Subtle Ambient Background Glows ──
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emerald.withValues(alpha: 0.04), // Very light emerald glow
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.03), // Very light gold glow
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AppBar
                _buildAppBar(context),

                // Scrollable metrics
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1: Digital Premium Eco Card
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 50),
                          child: _buildDigitalEcoCard(),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Header Filter Row (+12.5% & Dropdown)
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 100),
                          child: _buildFilterRow(),
                        ),
                        const SizedBox(height: 16),

                        // Section 3: Consistency Line Chart Curve (Stunning Gradient Curve)
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 150),
                          child: _buildConsistencyLineChartCard(),
                        ),
                        const SizedBox(height: 20),

                        // Section 4: Points Gained & Redeemed Stack (With Sparklines)
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 200),
                          child: _buildPointsTransactionCards(),
                        ),
                        const SizedBox(height: 20),

                        // Section 5: Weekly Contribution Bar Chart
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 250),
                          child: _buildBarChartCard(),
                        ),
                        const SizedBox(height: 20),

                        // Section 6: Environmental Impact Metrics Grid
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 300),
                          child: _buildImpactMetricsGrid(),
                        ),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          Text(
            'Ringkasan Statistik',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          // User profile avatar
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.navy50,
              backgroundImage: _profile?.avatarUrl != null
                  ? NetworkImage(_profile!.avatarUrl!)
                  : const NetworkImage(
                      'https://api.dicebear.com/7.x/bottts/png?seed=GenesisUser',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalEcoCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy900.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Dark Gradient Base (Remains premium dark for card visual contrast)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0F3A2E), // Subtle Emerald Shift
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Card Decorative Shapes
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 12),
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              right: -20,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Card Title & NFC Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KARTU ECO GUARDIAN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Genesis Digital Identity',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.wifi_rounded, color: Colors.white30, size: 20),
                          const SizedBox(width: 8),
                          Icon(Icons.nfc_rounded, color: AppColors.emerald.withValues(alpha: 0.8), size: 24),
                        ],
                      ),
                    ],
                  ),

                  // Middle Row: Spaced Card Number
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '8812   4021   1953   2026',
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 22,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  // Bottom Row: Holder Name & Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PEMEGANG KARTU',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white38,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fullName.toUpperCase(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'SALDO POIN',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white38,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.gold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$_totalPoints Pts',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.trending_up_rounded, color: AppColors.emerald, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+12.5% Aktivitas',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Dibanding bulan lalu',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Premium Pill Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 1.2),
          ),
          child: InkWell(
            onTap: _showPeriodPicker,
            child: Row(
              children: [
                Text(
                  _selectedPeriod,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                  'Pilih Rentang Waktu',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Minggu Ini', style: TextStyle(color: AppColors.textPrimary)),
                  trailing: _selectedPeriod == 'Minggu Ini' ? const Icon(Icons.check, color: AppColors.emerald) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'Minggu Ini');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Bulan Ini', style: TextStyle(color: AppColors.textPrimary)),
                  trailing: _selectedPeriod == 'Bulan Ini' ? const Icon(Icons.check, color: AppColors.emerald) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'Bulan Ini');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Tahun Ini', style: TextStyle(color: AppColors.textPrimary)),
                  trailing: _selectedPeriod == 'Tahun Ini' ? const Icon(Icons.check, color: AppColors.emerald) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'Tahun Ini');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsistencyLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Keaktifan XP',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Aktif',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.emerald,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tren perolehan XP dalam 7 bulan terakhir',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 24),
          // Custom Painter for Line Chart
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: WeeklyConsistencyCurvePainter(
                points: [20, 35, 15, 55, 40, 70, 65], // Activity points trend
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsTransactionCards() {
    return Column(
      children: [
        // Gained Points Card
        _buildTransactionCard(
          isGained: true,
          title: 'Poin Diperoleh',
          subtitle: 'Aktivitas Daur Ulang & Misi',
          amount: '+$_xp XP',
          sparklineData: [10, 15, 8, 25, 18, 30, 35],
          lineColor: AppColors.emerald,
        ),
        const SizedBox(height: 12),
        // Redeemed Points Card
        _buildTransactionCard(
          isGained: false,
          title: 'Poin Ditukarkan',
          subtitle: 'Klaim Voucher & Reward',
          amount: '-${(_xp * 0.15).round()} Pts',
          sparklineData: [20, 18, 25, 12, 14, 5, 2],
          lineColor: AppColors.navy500,
        ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required bool isGained,
    required String title,
    required String subtitle,
    required String amount,
    required List<double> sparklineData,
    required Color lineColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 1.2),
      ),
      child: Row(
        children: [
          // Left Icon Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGained ? AppColors.emerald.withValues(alpha: 0.1) : AppColors.navy100.withValues(alpha: 0.5),
            ),
            child: Icon(
              isGained ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isGained ? AppColors.emerald : AppColors.navy600,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Center Text
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          // Right Sparkline Chart
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 36,
              child: CustomPaint(
                painter: MiniSparklinePainter(data: sparklineData, lineColor: lineColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laporan Tersalurkan',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  'Minggu Ini',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Custom Painter for Bar Chart
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: DailyContributionBarChartPainter(
                values: [3, 5, 2, 6, 4, 1, 3], // Mon - Sun reports count
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildImpactMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Dampak Lingkungan',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.co2_rounded,
                title: 'Reduksi Karbon',
                value: '${(_completedReports * 1.5).toStringAsFixed(1)} kg',
                subtitle: 'Setara CO2',
                iconColor: AppColors.emerald,
                backgroundColor: AppColors.emerald.withValues(alpha: 0.04),
                borderColor: AppColors.emerald.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.delete_outline_rounded,
                title: 'Sampah Terolah',
                value: '${(_completedReports * 1.2).toStringAsFixed(1)} kg',
                subtitle: 'Plastik & Organik',
                iconColor: const Color(0xFF38BDF8),
                backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.04),
                borderColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildFullWidthMetricCard(
          icon: Icons.stars_rounded,
          title: 'Poin Daur Ulang',
          value: '$_totalPoints Poin',
          subtitle: 'Koin siap ditukarkan dengan hadiah voucher belanja',
          iconColor: AppColors.gold,
          backgroundColor: AppColors.gold.withValues(alpha: 0.04),
          borderColor: AppColors.gold.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter: Mini Sparkline ──
class MiniSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  MiniSparklinePainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double spacing = size.width / (data.length - 1);
    final double maxVal = data.reduce((curr, next) => curr > next ? curr : next);
    final double minVal = data.reduce((curr, next) => curr < next ? curr : next);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final Path path = Path();
    final double firstY = size.height - ((data[0] - minVal) / range) * size.height;
    path.moveTo(0, firstY);

    for (int i = 1; i < data.length; i++) {
      final double x = spacing * i;
      final double y = size.height - ((data[i] - minVal) / range) * size.height;
      path.lineTo(x, y);
    }

    final Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MiniSparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.lineColor != lineColor;
}

// ── Custom Painter: Daily Contribution Bar Chart ──
class DailyContributionBarChartPainter extends CustomPainter {
  final List<int> values;

  DailyContributionBarChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final double spacing = size.width / (values.length + 1);
    final double maxVal = values.reduce((curr, next) => curr > next ? curr : next).toDouble();
    final double bottomMargin = 24.0;
    final double chartHeight = size.height - bottomMargin;
    final double barWidth = 14.0;

    final Paint barPaintBg = Paint()
      ..color = AppColors.navy50
      ..style = PaintingStyle.fill;

    final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    for (int i = 0; i < values.length; i++) {
      final double x = spacing * (i + 1);
      
      // Draw background track
      final RRect trackRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(x - barWidth / 2, 0, x + barWidth / 2, chartHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(trackRect, barPaintBg);

      // Draw filled bar
      final double normHeight = (values[i] / maxVal) * chartHeight;
      final double top = chartHeight - normHeight;

      if (values[i] > 0) {
        final Paint barPaintFill = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ).createShader(Rect.fromLTRB(x - barWidth / 2, top, x + barWidth / 2, chartHeight))
          ..style = PaintingStyle.fill;

        final RRect fillRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(x - barWidth / 2, top, x + barWidth / 2, chartHeight),
          const Radius.circular(8),
        );
        canvas.drawRRect(fillRect, barPaintFill);
      }

      // Draw label
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DailyContributionBarChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

// ── Custom Painter: Weekly Consistency Curve ──
class WeeklyConsistencyCurvePainter extends CustomPainter {
  final List<int> points;

  WeeklyConsistencyCurvePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double spacing = size.width / (points.length - 1);
    final double maxVal = points.reduce((curr, next) => curr > next ? curr : next).toDouble();
    final double chartHeight = size.height;

    final List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final double x = spacing * i;
      final double normHeight = (points[i] / maxVal) * (chartHeight - 30); // Padded at top
      final double y = chartHeight - 20 - normHeight;
      offsets.add(Offset(x, y));
    }

    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final double y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw smooth curve using cubic bezier path
    final Path path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final Offset p0 = offsets[i];
      final Offset p1 = offsets[i + 1];
      final double controlPointX = p0.dx + (p1.dx - p0.dx) / 2;
      
      path.cubicTo(
        controlPointX, p0.dy,
        controlPointX, p1.dy,
        p1.dx, p1.dy,
      );
    }

    // Fill under path
    final Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height - 15);
    fillPath.lineTo(0, size.height - 15);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.emerald.withValues(alpha: 0.12), AppColors.emerald.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke path
    final Paint strokePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF60A5FA)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, strokePaint);

    // Draw dots at points
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint dotBorderPaint = Paint()
      ..color = AppColors.navy500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final offset in offsets) {
      canvas.drawCircle(offset, 4.0, dotPaint);
      canvas.drawCircle(offset, 4.0, dotBorderPaint);
    }

    // Draw months label
    final List<String> labels = ['Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu'];
    for (int i = 0; i < points.length; i++) {
      final double x = spacing * i;
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartHeight - 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyConsistencyCurvePainter oldDelegate) =>
      oldDelegate.points != points;
}
