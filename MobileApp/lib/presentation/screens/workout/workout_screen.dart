import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _heartBeatController;

  int selectedTab = 0;
  bool isWorkoutActive = false;
  int currentExercise = 2; // Currently on exercise 3 of 8

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

    _heartBeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _heartBeatController.dispose();
    super.dispose();
  }

  void _toggleWorkout() {
    setState(() {
      isWorkoutActive = !isWorkoutActive;
    });
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
              children: [
                _buildWorkoutTabs(),
                const SizedBox(height: 24),
                if (selectedTab == 0) ...[
                  _buildTodaysWorkout(),
                  const SizedBox(height: 24),
                  _buildExercisesList(),
                  const SizedBox(height: 24),
                  _buildWorkoutStats(),
                ] else if (selectedTab == 1) ...[
                  _buildWorkoutHistory(),
                ] else ...[
                  _buildWorkoutPlans(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildStartWorkoutFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildCosmicAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Workout Tracker',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: _heartBeatController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 +
                  (math.sin(_heartBeatController.value * 2 * math.pi) * 0.1),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Color(0xFFEF4444)),
                onPressed: () {},
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.timer, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Today', 0)),
          Expanded(child: _buildTabButton('History', 1)),
          Expanded(child: _buildTabButton('Plans', 2)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysWorkout() {
    return _buildCosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.fitness_center,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Workout',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upper Body Strength',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '45 minutes • 8 exercises',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              if (isWorkoutActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFEF4444), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Workout Progress
          Row(
            children: [
              Expanded(
                  child: _buildProgressCard(
                      'Time', '12:34', '45:00', const Color(0xFF6366F1), 0.28)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildProgressCard('Exercises', '$currentExercise',
                      '8', const Color(0xFF8B5CF6), currentExercise / 8)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildProgressCard(
                      'Calories', '85', '350', const Color(0xFFEF4444), 0.24)),
            ],
          ),

          const SizedBox(height: 20),

          // Heart Rate Monitor
          if (isWorkoutActive) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _heartBeatController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 +
                            (math.sin(
                                    _heartBeatController.value * 2 * math.pi) *
                                0.2),
                        child: const Icon(Icons.favorite,
                            color: Color(0xFFEF4444), size: 24),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heart Rate',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        '142 BPM',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Zone: Cardio',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Control Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _toggleWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWorkoutActive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isWorkoutActive ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    isWorkoutActive ? 'Pause Workout' : 'Start Workout',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isWorkoutActive) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isWorkoutActive = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.stop, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    final exercises = [
      {
        'name': 'Push-ups',
        'sets': '3 sets × 15 reps',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF6366F1),
        'completed': true
      },
      {
        'name': 'Dumbbell Rows',
        'sets': '3 sets × 12 reps',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF8B5CF6),
        'completed': true
      },
      {
        'name': 'Shoulder Press',
        'sets': '3 sets × 10 reps',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFF10B981),
        'completed': false,
        'current': true
      },
      {
        'name': 'Bicep Curls',
        'sets': '3 sets × 12 reps',
        'icon': Icons.sports_gymnastics,
        'color': const Color(0xFFF59E0B),
        'completed': false
      },
      {
        'name': 'Tricep Dips',
        'sets': '3 sets × 10 reps',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFEF4444),
        'completed': false
      },
      {
        'name': 'Plank',
        'sets': '3 sets × 60 seconds',
        'icon': Icons.timer,
        'color': const Color(0xFF22D3EE),
        'completed': false
      },
      {
        'name': 'Lateral Raises',
        'sets': '3 sets × 15 reps',
        'icon': Icons.accessible_forward,
        'color': const Color(0xFF8B5CF6),
        'completed': false
      },
      {
        'name': 'Cool Down Stretch',
        'sets': '5 minutes',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF6366F1),
        'completed': false
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise List',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...exercises
            .map((exercise) => _buildExerciseCard(
                  exercise['name'] as String,
                  exercise['sets'] as String,
                  exercise['icon'] as IconData,
                  exercise['color'] as Color,
                  exercise['completed'] as bool,
                  current: exercise['current'] as bool? ?? false,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildWorkoutStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildCosmicCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Workouts', '12', 'This week'),
                  _buildStatItem('Total Time', '8.5h', 'This week'),
                  _buildStatItem('Calories', '2,450', 'Burned'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: 2, color: const Color(0xFF6366F1), width: 20)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: 3, color: const Color(0xFF6366F1), width: 20)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: 1, color: const Color(0xFF6366F1), width: 20)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: 4, color: const Color(0xFF6366F1), width: 20)
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(
                            toY: 2, color: const Color(0xFF6366F1), width: 20)
                      ]),
                      BarChartGroupData(x: 5, barRods: [
                        BarChartRodData(
                            toY: 0, color: const Color(0xFF374151), width: 20)
                      ]),
                      BarChartGroupData(x: 6, barRods: [
                        BarChartRodData(
                            toY: 1, color: const Color(0xFF6366F1), width: 20)
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistory() {
    final workouts = [
      {
        'name': 'Upper Body Strength',
        'date': 'Yesterday',
        'duration': '45 min',
        'calories': '350 cal',
        'color': const Color(0xFF6366F1)
      },
      {
        'name': 'Cardio HIIT',
        'date': '2 days ago',
        'duration': '30 min',
        'calories': '280 cal',
        'color': const Color(0xFFEF4444)
      },
      {
        'name': 'Full Body Workout',
        'date': '3 days ago',
        'duration': '60 min',
        'calories': '420 cal',
        'color': const Color(0xFF10B981)
      },
      {
        'name': 'Leg Day',
        'date': '4 days ago',
        'duration': '50 min',
        'calories': '380 cal',
        'color': const Color(0xFF8B5CF6)
      },
      {
        'name': 'Core & Abs',
        'date': '5 days ago',
        'duration': '25 min',
        'calories': '180 cal',
        'color': const Color(0xFFF59E0B)
      },
      {
        'name': 'Yoga Flow',
        'date': '6 days ago',
        'duration': '40 min',
        'calories': '120 cal',
        'color': const Color(0xFF22D3EE)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout History',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...workouts
            .map((workout) => _buildHistoryCard(
                  workout['name'] as String,
                  workout['date'] as String,
                  workout['duration'] as String,
                  workout['calories'] as String,
                  workout['color'] as Color,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildWorkoutPlans() {
    final plans = [
      {
        'name': 'Beginner Strength',
        'duration': '3 weeks • 4 days/week',
        'description': 'Build foundation',
        'color': const Color(0xFF10B981)
      },
      {
        'name': 'HIIT Cardio Blast',
        'duration': '4 weeks • 3 days/week',
        'description': 'Burn fat fast',
        'color': const Color(0xFFEF4444)
      },
      {
        'name': 'Muscle Building',
        'duration': '6 weeks • 5 days/week',
        'description': 'Gain muscle mass',
        'color': const Color(0xFF6366F1)
      },
      {
        'name': 'Flexibility & Mobility',
        'duration': '2 weeks • Daily',
        'description': 'Improve flexibility',
        'color': const Color(0xFF8B5CF6)
      },
      {
        'name': 'Fat Loss Circuit',
        'duration': '4 weeks • 4 days/week',
        'description': 'Lean & strong',
        'color': const Color(0xFFF59E0B)
      },
      {
        'name': 'Athletic Performance',
        'duration': '8 weeks • 5 days/week',
        'description': 'Peak performance',
        'color': const Color(0xFF22D3EE)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Plans',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...plans
            .map((plan) => _buildPlanCard(
                  plan['name'] as String,
                  plan['duration'] as String,
                  plan['description'] as String,
                  plan['color'] as Color,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildStartWorkoutFAB() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: _toggleWorkout,
            backgroundColor: isWorkoutActive
                ? const Color(0xFFEF4444)
                : const Color(0xFF6366F1),
            icon: Icon(
              isWorkoutActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            label: Text(
              isWorkoutActive ? 'Pause' : 'Start',
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
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProgressCard(String title, String current, String total,
      Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
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
            '/ $total',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF374151),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String exercise, String details, IconData icon,
      Color color, bool isCompleted,
      {bool current = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: current
            ? color.withOpacity(0.15)
            : const Color(0xFF1F2937).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? color
              : isCompleted
                  ? color
                  : color.withOpacity(0.3),
          width: current ? 2 : 1,
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
                Row(
                  children: [
                    Text(
                      exercise,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (current) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CURRENT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  details,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isCompleted
                  ? Icons.check_circle
                  : current
                      ? Icons.play_circle_filled
                      : Icons.play_circle_outline,
              color: isCompleted ? const Color(0xFF10B981) : color,
            ),
            onPressed: () {
              if (current && !isCompleted) {
                // Start exercise
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(String workout, String date, String duration,
      String calories, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$date • $duration • $calories',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      String plan, String duration, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
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
            child: Icon(Icons.fitness_center, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Start workout plan
              _showWorkoutPlanDialog(plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(60, 32),
            ),
            child: Text(
              'Start',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Functions

  void _showWorkoutPlanDialog(String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Start $planName?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will replace your current workout plan. Are you sure you want to continue?',
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start the workout plan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$planName started!'),
                  backgroundColor: const Color(0xFF6366F1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: Text(
              'Start Plan',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
