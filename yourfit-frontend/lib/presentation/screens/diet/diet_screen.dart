import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  int selectedMealIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          color: const Color(0xFF6366F1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyCalorieOverview(),
                const SizedBox(height: 24),
                _buildMacronutrientBreakdown(),
                const SizedBox(height: 24),
                _buildMealPlan(),
                const SizedBox(height: 24),
                _buildNutritionGoals(),
                const SizedBox(height: 24),
                _buildNutritionChart(),
                const SizedBox(height: 24),
                _buildQuickAddButtons(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildAddMealFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildCosmicAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Nutrition Tracker',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF10B981).withOpacity(0.1),
              const Color(0xFF22D3EE).withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyCalorieOverview() {
    return _buildCosmicCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF22D3EE)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.restaurant, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Calories',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1,547 / 2,000 kcal',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 0.77 * _progressController.value,
                      backgroundColor: const Color(0xFF374151),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981)),
                      strokeWidth: 6,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroOverview(
                  'Protein', '85g', '120g', const Color(0xFF6366F1), 0.71),
              _buildMacroOverview(
                  'Carbs', '180g', '250g', const Color(0xFF10B981), 0.72),
              _buildMacroOverview(
                  'Fat', '65g', '78g', const Color(0xFFF59E0B), 0.83),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macronutrient Breakdown',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildCosmicCard(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF6366F1),
                          value: 30,
                          title: '30%',
                          titleStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF10B981),
                          value: 45,
                          title: '45%',
                          titleStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFF59E0B),
                          value: 25,
                          title: '25%',
                          titleStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMacroLegend('Protein', '85g', const Color(0xFF6366F1)),
                  const SizedBox(height: 12),
                  _buildMacroLegend('Carbs', '180g', const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _buildMacroLegend('Fat', '65g', const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Meals',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildMealCard('Breakfast', 'Oatmeal with Berries & Protein',
            '420 kcal', Icons.wb_sunny, const Color(0xFFF59E0B), false),
        const SizedBox(height: 12),
        _buildMealCard('Lunch', 'Grilled Chicken Caesar Salad', '485 kcal',
            Icons.wb_sunny_outlined, const Color(0xFF10B981), false),
        const SizedBox(height: 12),
        _buildMealCard('Dinner', 'Tap to add meal', '0 kcal',
            Icons.nightlight_round, const Color(0xFF6366F1), true),
        const SizedBox(height: 12),
        _buildMealCard('Snacks', 'Greek Yogurt, Almonds', '285 kcal',
            Icons.cookie, const Color(0xFF8B5CF6), false),
      ],
    );
  }

  Widget _buildNutritionGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Goals',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildNutritionGoalCard(
                    'Fiber', '25g', '30g', const Color(0xFF10B981), 0.83)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildNutritionGoalCard(
                    'Sugar', '35g', '50g', const Color(0xFFEF4444), 0.70)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildNutritionGoalCard(
                    'Sodium', '1.8g', '2.3g', const Color(0xFFF59E0B), 0.78)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildNutritionGoalCard('Water', '6 cups', '8 cups',
                    const Color(0xFF22D3EE), 0.75)),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionChart() {
    return _buildCosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Nutrition Trends',
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
                  horizontalInterval: 500,
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
                      FlSpot(0, 1800),
                      FlSpot(1, 2100),
                      FlSpot(2, 1950),
                      FlSpot(3, 2200),
                      FlSpot(4, 1750),
                      FlSpot(5, 2400),
                      FlSpot(6, 1900),
                    ],
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withOpacity(0.1),
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

  Widget _buildQuickAddButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildQuickAddButton(
                    'Water', Icons.water_drop, const Color(0xFF22D3EE))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickAddButton(
                    'Snack', Icons.cookie, const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildQuickAddButton(
                    'Protein', Icons.fitness_center, const Color(0xFF6366F1))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickAddButton(
                    'Supplement', Icons.medication, const Color(0xFFF59E0B))),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMealFAB() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: () {
              _showAddMealDialog();
            },
            backgroundColor: const Color(0xFF10B981),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Meal',
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
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMacroOverview(String name, String current, String target,
      Color color, double progress) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '/ $target',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF374151),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroLegend(String name, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCard(String meal, String food, String calories,
      IconData icon, Color color, bool isEmpty) {
    return GestureDetector(
      onTap: () {
        if (isEmpty) {
          _showAddMealDialog();
        } else {
          _showMealDetailsDialog(meal, food, calories);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isEmpty ? const Color(0xFF9CA3AF) : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  calories,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isEmpty ? const Color(0xFF9CA3AF) : color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isEmpty)
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: const Color(0xFF9CA3AF),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionGoalCard(String title, String current, String target,
      Color color, double progress) {
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
            current,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '/ $target',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF374151),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _showQuickAddDialog(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Functions

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          'Add Meal',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Meal logging feature coming soon!',
          style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(color: const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetailsDialog(String meal, String food, String calories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          meal,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              calories,
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Edit',
              style: GoogleFonts.inter(color: const Color(0xFF10B981)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          'Add $item',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Quick add feature coming soon!',
          style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(color: const Color(0xFF10B981)),
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
