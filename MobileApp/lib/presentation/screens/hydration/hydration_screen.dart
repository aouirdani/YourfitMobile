import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _dropController;
  late AnimationController _progressController;

  int currentIntake = 6; // glasses of water
  int dailyGoal = 8;
  bool remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _dropController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dropController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _addWater() {
    if (currentIntake < dailyGoal) {
      setState(() {
        currentIntake++;
      });
      _dropController.forward().then((_) => _dropController.reset());
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentIntake / dailyGoal;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0B),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0A0A0B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildCosmicAppBar(),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          backgroundColor: const Color(0xFF1F2937),
          color: const Color(0xFF22D3EE),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHydrationOverview(progress),
                const SizedBox(height: 32),
                _buildWaterTracker(progress),
                const SizedBox(height: 32),
                _buildHydrationStats(),
                const SizedBox(height: 32),
                _buildHydrationChart(),
                const SizedBox(height: 32),
                _buildHydrationTips(),
                const SizedBox(height: 32),
                _buildReminderSettings(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildAddWaterFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildCosmicAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Hydration Tracker',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF22D3EE).withOpacity(0.1),
              const Color(0xFF6366F1).withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHydrationOverview(double progress) {
    return _buildCosmicCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Hydration',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentIntake / $dailyGoal glasses',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}% of goal completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF22D3EE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(double progress) {
    return _buildCosmicCard(
      child: Column(
        children: [
          Text(
            'Today\'s Progress',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Animated Water Circle
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress * _progressController.value,
                        strokeWidth: 12,
                        backgroundColor: const Color(0xFF374151),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                            const Color(0xFF22D3EE),
                            const Color(0xFF6366F1),
                            _waveController.value,
                          )!,
                        ),
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _dropController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_dropController.value * 0.3),
                              child: Icon(
                                Icons.water_drop,
                                size: 40,
                                color: const Color(0xFF22D3EE).withOpacity(
                                  0.7 + (_dropController.value * 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$currentIntake',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'glasses',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Water level indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dailyGoal, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  color: index < currentIntake
                      ? const Color(0xFF22D3EE)
                      : const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: index < currentIntake
                    ? const Icon(Icons.water_drop,
                        size: 16, color: Colors.white)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationStats() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Today', '${currentIntake * 250}ml', 'Volume',
                const Color(0xFF22D3EE))),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'This Week', '12.5L', 'Average', const Color(0xFF6366F1))),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Streak', '7 days', 'Goals met', const Color(0xFF10B981))),
      ],
    );
  }

  Widget _buildHydrationChart() {
    return _buildCosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Hydration Trends',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF374151),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(
                          days[value.toInt()],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 7),
                      FlSpot(1, 8),
                      FlSpot(2, 6),
                      FlSpot(3, 8),
                      FlSpot(4, 9),
                      FlSpot(5, 7),
                      FlSpot(6, 8),
                    ],
                    isCurved: true,
                    color: const Color(0xFF22D3EE),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF22D3EE).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTips() {
    return _buildCosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hydration Tips',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTip('Drink a glass of water when you wake up'),
          _buildTip('Keep a water bottle with you throughout the day'),
          _buildTip('Drink water before, during, and after exercise'),
          _buildTip('Choose water over sugary drinks'),
          _buildTip('Eat water-rich foods like fruits and vegetables'),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return _buildCosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications,
                    color: Color(0xFF22D3EE), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Reminders',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Every 2 hours • 9 AM - 9 PM',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: remindersEnabled,
                onChanged: (value) {
                  setState(() {
                    remindersEnabled = value;
                  });
                },
                activeColor: const Color(0xFF22D3EE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddWaterFAB() {
    return AnimatedBuilder(
      animation: _dropController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_dropController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: _addWater,
            backgroundColor: const Color(0xFF22D3EE),
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: Text(
              'Add Water',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Widgets

  Widget _buildCosmicCard(
      {required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22D3EE).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF22D3EE).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF22D3EE),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _progressController.reset();
    _progressController.forward();
  }
}
