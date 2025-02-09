import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final Function(Trade) onTap;  // 탭 이벤트를 처리할 콜백 함수 추가

  const TradeCard({
    super.key,
    required this.trade,
    required this.onTap,  // 필수 파라미터로 추가
  });

  // 날짜 포맷을 처리하는 함수
  String formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();
    final bool isToday = dateTime.year == now.year && 
                        dateTime.month == now.month && 
                        dateTime.day == now.day;
    
    // 어제 날짜인지 확인
    final bool isYesterday = dateTime.year == now.year &&
                            dateTime.month == now.month &&
                            dateTime.day == now.day - 1;

    if (isToday) {
      // 오전/오후를 직접 처리
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour <= 12 ? hour : hour - 12;
      
      return '$period $displayHour:$minute';
    } else if (isYesterday) {
      // 어제인 경우 '어제 HH:mm' 형식
      return '어제 ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // 그 외의 경우 'M/d HH:mm' 형식
      return DateFormat('M/d HH:mm').format(dateTime);
    }
  }

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

    // decision 값에 따른 이모지를 가져오는 함수
    String getDecisionEmoji() {
      switch (trade.decision.toUpperCase()) {
        case 'BUY':
          return '🔥 ';
        case 'SELL':
          return '✅ ';
        case 'HOLD':
          return '⬛️ ';
        default:
          return '';
      }
    }

    return GestureDetector(
      onTap: () => onTap(trade),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 왼쪽: decision에 따른 이미지
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    getDecisionImage(),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              
              // 중앙: 거래 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${getDecisionEmoji()}${trade.decision}',
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat('#,###').format(trade.price / 1000),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // 오른쪽: timestamp
              Text(
                formatTimestamp(trade.timestamp),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 