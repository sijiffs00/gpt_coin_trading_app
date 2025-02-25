import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/pie_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class GraphPage extends StatefulWidget {
  final List<Trade> trades;
  final List<FlSpot> btcPrices;

  const GraphPage({
    super.key,
    required this.trades,
    required this.btcPrices,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    // 최소값과 최대값 계산
    final minY = widget.btcPrices.map((spot) => spot.y).reduce(math.min) - 500;
    final maxY = widget.btcPrices.map((spot) => spot.y).reduce(math.max) + 500;

    return Container(
      color: const Color(0xFFF8F9FD),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.btcPrices.isEmpty
                ? btcDataNone()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LineChart(
                          LineChartData(
                            minY: minY,
                            maxY: maxY,
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: widget.btcPrices,
                                isCurved: true,
                                color: const Color(0xFFA177FF),
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFFA177FF).withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            totalTradeCount(),
            const SizedBox(height: 32),
            PieChartWidget(trades: widget.trades),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget btcDataNone() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,24,16,16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 50,
              top: 38,
              child: Text(
                'BTC 가격 데이터 ... 없어 ..',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF7C7D8B),
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 10,
              child: Image.asset(
                'assets/die_gom.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),

            Positioned(
              right: 30,
              bottom: 28,
              child: InkWell(
                onTap: () {
                  print('재시도');
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),                
                  child: Text('📡 재시도', style: TextStyle(fontSize: 24),)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget totalTradeCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Total  : ',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          widget.trades.length.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'LINESeedKR',
          ),
        ),
        const Text(
          ' 건',
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
