import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/my_wallet_widget.dart';

class GraphPage extends StatefulWidget {
  final List<Trade> trades;

  const GraphPage({
    super.key,
    required this.trades,
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
            const MyWalletWidget(),
            totalTradeCount(),
            PieChartWidget(trades: widget.trades),
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
