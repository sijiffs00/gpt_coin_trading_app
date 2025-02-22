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
    return const Center(
      child: Text('그래프 페이지'),  // 나중에 실제 그래프 구현
    );
  }
} 