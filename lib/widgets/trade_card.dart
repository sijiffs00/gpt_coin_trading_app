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
      switch (trade.decision?.toUpperCase() ?? 'UNKNOWN') {
        case 'BUY':
          return 'assets/buy_img.JPG';
        case 'SELL':
          return 'assets/sell_img.JPG';
        case 'HOLD':
          return 'assets/hold_img.JPG';
        default:
          return 'assets/hold_img.JPG';
      }
    }


    return GestureDetector(
      onTap: () => onTap(trade),
      child: Card(
        margin: const EdgeInsets.all(8),
        color: const Color(0xFFFFFFFF),  // 흰색으로 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),  // 모서리 둥글기를 16으로 설정
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 왼쪽: decision에 따른 이미지
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                    getDecisionImage(),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                
              ),
              const SizedBox(width: 32),
              
              // 중앙: 거래 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // decision과 percentage를 한 줄에
                    Row(
                      children: [
                        Text(
                          trade.decision ?? 'UNKNOWN',
                          style: const TextStyle(
                            fontSize: 21, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xff313C4B)
                          ),
                        ),
                        const SizedBox(width: 8),  // 간격 추가
                        // percentage는 BUY/SELL일 때만
                        if (trade.decision?.toUpperCase() == 'BUY' || 
                            trade.decision?.toUpperCase() == 'SELL')
                          Text(
                            '${trade.percentage}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: trade.decision?.toUpperCase() == 'BUY' 
                                  ? const Color(0xFFFF3B30)  // BUY: 빨간색
                                  : const Color(0xFF007AFF), // SELL: 파란색
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat('#,###').format((trade.price ?? 0) / 1000),
                      style: const TextStyle(fontSize: 14, color: Color(0xff697584)),
                    ),
                  ],
                ),
              ),

              // 오른쪽: timestamp만
              Text(
                formatTimestamp(trade.timestamp ?? ''),
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