import 'package:flutter/material.dart';
import '../models/trade.dart';

class TradeDetailPage extends StatelessWidget {
  final Trade trade;

  const TradeDetailPage({
    super.key,
    required this.trade,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${trade.decision}'),  // 여기서 decision에 맞는 타이틀 사용
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
            if (trade.img != null) 
              Container(
                width: 150,
                height: 150,
                child: Image.network(
                  trade.img!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            // 거래 정보
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '가격: ${trade.price ?? '없음'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '시간: ${trade.timestamp ?? '없음'}',
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
                      trade.reason ?? '매매 이유 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,  // 줄 간격을 조금 넓게
                      ),
                    ),
                  ],
                ),
              
            ),
          ],
        ),
      ),
    );
  }
} 