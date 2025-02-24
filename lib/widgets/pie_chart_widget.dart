import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trade.dart';

class PieChartWidget extends StatefulWidget {
  final List<Trade> trades;

  const PieChartWidget({
    super.key,
    required this.trades,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> with SingleTickerProviderStateMixin {
  double startDegreeOffset = 0;
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: 0,
      end: 150,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    setState(() {
      startDegreeOffset = 270;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buyCount = widget.trades.where((trade) => trade.decision == 'buy').length;
    final sellCount = widget.trades.where((trade) => trade.decision == 'sell').length;
    final holdCount = widget.trades.where((trade) => trade.decision == 'hold').length;
    final total = widget.trades.length;

    return Column(
      children: [
        // 범례
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('buy', const Color(0xFF2DC76D), '$buyCount건'),
            const SizedBox(height: 10),
            _buildLegendItem('sell', const Color(0xFF007FFF), '$sellCount건'),
            const SizedBox(height: 10),
            _buildLegendItem('hold', const Color(0xFF868697), '$holdCount건'),
          ],
        ),

        // 파이차트
        SizedBox(
          height: 400,
          width: MediaQuery.of(context).size.width,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: buyCount.toDouble(),
                      title: 'buy\n${(buyCount / total * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFF2DC76D),
                      radius: _radiusAnimation.value,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      titlePositionPercentageOffset: 0.5,
                    ),
                    PieChartSectionData(
                      value: sellCount.toDouble(),
                      title: 'sell\n${(sellCount / total * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFF007FFF),
                      radius: _radiusAnimation.value,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      titlePositionPercentageOffset: 0.5,
                    ),
                    PieChartSectionData(
                      value: holdCount.toDouble(),
                      title: 'hold\n${(holdCount / total * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFF868697),
                      radius: _radiusAnimation.value,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      titlePositionPercentageOffset: 0.5,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  startDegreeOffset: startDegreeOffset,
                  pieTouchData: PieTouchData(
                    touchCallback: (_, __) {},
                    enabled: true,
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeOutQuad,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String count) {
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            count, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 