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

    if (isToday) {
      // 오전/오후를 직접 처리
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour <= 12 ? hour : hour - 12;
      
      return '$period $displayHour:$minute';
    } else {
      // 다른 날짜면 'M/d HH:mm' 형식
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

    return GestureDetector(  // Card를 GestureDetector로 감싸기
      onTap: () => onTap(trade),  // 탭했을 때 콜백 함수 호출
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // 왼쪽: decision에 따른 이미지
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,  // 테두리 색상
                    width: 2.0,          // 테두리 굵기
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
              const SizedBox(width: 16),
              
              // 오른쪽: 거래 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decision 표시 (차트 이미지 제거)
                    Text(
                      '${getDecisionEmoji()}${trade.decision}',
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat('#,###').format(trade.price / 1000),  // 천 단위 구분 쉼표 추가
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
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
            ],
          ),
        ),
      ),
    );
  }
} 