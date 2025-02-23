import 'package:flutter/material.dart';
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '총 ${trades.length}건의 매매기록이 있습니다',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(
            '매수(buy): $buyCount건\n'
            '매도(sell): $sellCount건\n'
            '관망(hold): $holdCount건',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          const Text('여기에 그래프가 들어갈 예정입니다'),
        ],
      ),
    );
  }
} 