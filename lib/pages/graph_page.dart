import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trade.dart';

class GraphPage extends StatelessWidget {
  final List<Trade> trades;
  
  const GraphPage({
    super.key,
    required this.trades,
  });

  @override
  Widget build(BuildContext context) {
    // decision별 건수를 계산
    final buyCount = trades.where((trade) => trade.decision == 'buy').length;
    final sellCount = trades.where((trade) => trade.decision == 'sell').length;
    final holdCount = trades.where((trade) => trade.decision == 'hold').length;
    final total = trades.length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total : ${trades.length}건',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),

          // 파이차트를 더 크게 만들기
          SizedBox(
            height: 400,  // 높이를 300에서 400으로 증가
            width: 400,   // 너비도 지정
            child: Stack(  // Stack을 사용해서 차트와 텍스트를 겹치게 배치
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: buyCount.toDouble(),
                        title: 'buy\n${(buyCount / total * 100).toStringAsFixed(1)}%',  // 텍스트 추가
                        color: const Color(0xFF2DC76D),  // buy 색상
                        radius: 150,  // 반지름을 100에서 150으로 증가
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,  // 글자 크기 증가
                          fontWeight: FontWeight.bold,
                        ),
                        titlePositionPercentageOffset: 0.5,  // 텍스트 위치 조정
                      ),
                      PieChartSectionData(
                        value: sellCount.toDouble(),
                        title: 'sell\n${(sellCount / total * 100).toStringAsFixed(1)}%',  // 텍스트 추가
                        color: const Color(0xFF007FFF),  // sell 색상
                        radius: 150,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        titlePositionPercentageOffset: 0.5,
                      ),
                      PieChartSectionData(
                        value: holdCount.toDouble(),
                        title: 'hold\n${(holdCount / total * 100).toStringAsFixed(1)}%',  // 텍스트 추가
                        color: const Color(0xFF868697),  // hold 색상
                        radius: 150,
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 범례 추가
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('buy', const Color(0xFF2DC76D), '$buyCount건'),
              const SizedBox(height: 10),  // width를 height로 변경
              _buildLegendItem('sell', const Color(0xFF007FFF), '$sellCount건'),
              const SizedBox(height: 10),  // width를 height로 변경
              _buildLegendItem('hold', const Color(0xFF868697), '$holdCount건'),
            ],
          ),
        ],
      ),
    );
  }

  // 범례 아이템을 만드는 위젯 수정
  Widget _buildLegendItem(String label, Color color, String count) {
    return Container(
      width: 150,  // 전체 너비를 고정
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
          const Spacer(),  // 남은 공간을 채워서 count를 오른쪽으로 밀어냄
          Text(
            count, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 