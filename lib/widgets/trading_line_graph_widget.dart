import 'package:flutter/material.dart';
import '../models/trade.dart';

class TradingLineGraphWidget extends StatelessWidget {
  final List<Trade> trades;

  const TradingLineGraphWidget({
    Key? key,
    required this.trades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9E7FE),  
              Color(0xFFDAFCFC),  
            ],
          ),
        ),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '거래 그래프',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 여기에 실제 그래프를 그리는 코드가 들어갈 수 있어
            // 지금은 간단한 예시로 텍스트만 표시할게
            Text(
              '${trades.length}개의 거래 데이터가 있어요',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 