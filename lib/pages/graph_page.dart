import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trade.dart';

// StatelessWidget에서 StatefulWidget으로 변경
class GraphPage extends StatefulWidget {
  final List<Trade> trades;
  
  const GraphPage({
    super.key,
    required this.trades,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> with SingleTickerProviderStateMixin {
  // 애니메이션 상태를 관리할 변수들
  double startDegreeOffset = 0;
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 시간 단축
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 반지름 애니메이션 설정
    _radiusAnimation = Tween<double>(
      begin: 0,
      end: 150,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,  // 이 효과는 유지
    ));

    // 딜레이 없이 바로 시작
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
    // decision별 건수를 계산
    final buyCount = widget.trades.where((trade) => trade.decision == 'buy').length;
    final sellCount = widget.trades.where((trade) => trade.decision == 'sell').length;
    final holdCount = widget.trades.where((trade) => trade.decision == 'hold').length;
    final total = widget.trades.length;

    return Container(  // Center를 Container로 감싸기
      color: const Color(0xFFF8F9FD),  // 매매기록 탭과 동일한 배경색 적용
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total  : ',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  widget.trades.length.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'LINESeedKR',
                    ),
                ),  
                Text(
                  ' 건',
                  style: const TextStyle(fontSize: 20),
                ),                              
              ],
            ),

            SizedBox(height: 32),

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
            

            Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: buyCount.toDouble(),
                              title: 'buy\n${(buyCount / total * 100).toStringAsFixed(1)}%',
                              color: const Color(0xFF2DC76D),
                              radius: _radiusAnimation.value,  // 애니메이션되는 반지름 사용
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
                              radius: _radiusAnimation.value,  // 애니메이션되는 반지름 사용
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
                              radius: _radiusAnimation.value,  // 애니메이션되는 반지름 사용
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
                        swapAnimationDuration: const Duration(milliseconds: 800),  // 1500 -> 800으로 단축
                        swapAnimationCurve: Curves.easeOutQuad,  // 더 부드러운 효과로 변경
                      );
                    },
                  ),
                ],
              ),
            ),
            

          ],
        ),
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