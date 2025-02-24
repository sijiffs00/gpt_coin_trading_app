import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/upbit_service.dart';
import 'dart:math' show min, max;  // 맨 위에 추가

class BtcPricesLineChart extends StatefulWidget {
  final List<FlSpot> prices;  // List<List<num>> 대신 FlSpot 리스트로 변경

  const BtcPricesLineChart({
    super.key,
    required this.prices,
  });

  @override
  State<BtcPricesLineChart> createState() => _BtcPricesLineChartState();
}

class _BtcPricesLineChartState extends State<BtcPricesLineChart> with SingleTickerProviderStateMixin {
  // 로딩 상태 제거
  // bool isLoading = true;
  // String? error;

  // 애니메이션 컨트롤러
  late final AnimationController _controller;
  late final Animation<double> _animation;

  // 비트코인 가격 데이터를 저장할 변수
  late List<FlSpot> btcPrices;
  
  // 캐시된 min/max 값
  late final double _minY;
  late final double _maxY;

  @override
  void initState() {
    super.initState();
    // min/max 값을 한 번만 계산
    _minY = widget.prices.map((e) => e.y).reduce(min);
    _maxY = widget.prices.map((e) => e.y).reduce(max);
    
    _setupAnimation();
    // 최초 한 번만 애니메이션 실행
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
      // 애니메이션 반복 방지
      if (status == AnimationStatus.completed) {
        _controller.stop();
      }
    });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 체크 제거
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    // if (error != null) {
    //   return Center(child: Text(error!));
    // }

    // 데이터가 비어있는 경우 처리
    if (widget.prices.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    return RepaintBoundary(
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: widget.prices,
                isCurved: false,
                color: const Color(0xFF2DC76D),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF2DC76D).withOpacity(0.1),
                ),
              ),
            ],
            // 그리드 간격 조절
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5000,  // 1000 -> 5000
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF868697),
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  // 간격을 더 넓게
                  interval: 45 * 24 * 60 * 60 * 1000,  // 30일 -> 45일
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.month}월',
                        style: const TextStyle(
                          color: Color(0xFF868697),
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: widget.prices.first.x,
            maxX: widget.prices.last.x,
            minY: _minY * 0.95,
            maxY: _maxY * 1.05,
          ),
        ),
      ),
    );
  }
} 