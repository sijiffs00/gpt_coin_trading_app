import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/pie_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';

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
    return Container(
      color: const Color(0xFFF8F9FD),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.btcPrices.isEmpty
                ? btcDataNone()
                : Container(), // 임시로 빈 컨테이너 추가

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
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFEEEEF0),
        ),
        child: const Center(
          child: Text(
            '비트코인 가격데이터가 없어요.. 😅',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7C7D8B),
            ),
          ),
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
