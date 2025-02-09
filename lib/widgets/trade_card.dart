import 'package:flutter/material.dart';
import '../models/trade.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;

  const TradeCard({
    super.key,
    required this.trade,
  });

  @override
  Widget build(BuildContext context) {
    // decision 값에 따른 이미지 경로를 가져오는 함수
    String getDecisionImage() {
      switch (trade.decision.toUpperCase()) {  // 대문자로 변환해서 비교
        case 'BUY':
          return 'assets/buy_img.JPG';
        case 'SELL':
          return 'assets/sell_img.JPG';
        case 'HOLD':
          return 'assets/hold_img.JPG';
        default:
          return 'assets/hold_img.JPG';  // 기본값
      }
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // 왼쪽: decision에 따른 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                getDecisionImage(),  // 함수 사용
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            
            // 오른쪽: 거래 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decision과 차트 이미지를 한 줄에 표시
                  Row(
                    children: [
                      Text(
                        trade.decision,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 차트 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          trade.img,
                          width: 25,  // 작은 크기로 조절
                          height: 25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💲 ${trade.price.toStringAsFixed(0)}원',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⏰ ${trade.timestamp}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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