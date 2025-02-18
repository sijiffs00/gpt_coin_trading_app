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

  // decision에 따른 스타일 정보를 한번에 관리하는 함수
  Map<String, dynamic> getDecisionStyle() {
    switch (trade.decision?.toUpperCase() ?? 'UNKNOWN') {
      case 'BUY':
        return {
          'image': 'assets/buy_img.png',
          'backgroundColor': const Color(0x332DC76D),  // 초록색 배경
        };
      case 'SELL':
        return {
          'image': 'assets/sell_img.png',
          'backgroundColor': const Color(0x33007FFF),  // 파란색 배경
        };
      case 'HOLD':
        return {
          'image': 'assets/hold_img.png',
          'backgroundColor': const Color(0x33868697),  // 회색 배경
        };
      default:
        return {
          'image': 'assets/hold_img.png',
          'backgroundColor': const Color(0xFFF5F5F5),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionStyle = getDecisionStyle();  // 스타일 정보 가져오기

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            // 첫 번째 그림자 - 가장 멀리 퍼지는 연한 그림자
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 12,
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            // 두 번째 그림자
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 6,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            // 세 번째 그림자
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            // 네 번째 그림자 - 가장 진한 그림자
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => onTap(trade),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 왼쪽: decision에 따른 이미지
                Container(
                  decoration: BoxDecoration(
                    color: decisionStyle['backgroundColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    decisionStyle['image'],
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
                                    ? const Color(0xFF2DC76D)  // BUY일 때는 초록색 
                                    : const Color(0xFF007FFF), // SELL일 때는 파란색 
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
      ),
    );
  }
} 