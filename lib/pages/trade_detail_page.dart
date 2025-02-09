import 'package:flutter/material.dart';
import '../models/trade.dart';

class TradeDetailPage extends StatelessWidget {
  final Trade trade;

  const TradeDetailPage({
    super.key,
    required this.trade,
  });

  // decision에 따른 타이틀을 반환하는 함수
  String getDecisionTitle() {
    switch (trade.decision.toUpperCase()) {
      case 'BUY':
        return '🔥';
      case 'SELL':
        return '✅';
      case 'HOLD':
        return '⬛️';
      default:
        return trade.decision;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getDecisionTitle()),  // 여기서 decision에 맞는 타이틀 사용
        elevation: 8,
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 차트 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                trade.img,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // 거래 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '매매 결정: ${trade.decision}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '가격: ${trade.price}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '시간: ${trade.timestamp}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // 매매 이유 추가
                    const Text(
                      '매매 이유',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trade.reason,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,  // 줄 간격을 조금 넓게
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 