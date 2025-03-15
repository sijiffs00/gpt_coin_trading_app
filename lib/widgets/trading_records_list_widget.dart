import 'package:flutter/material.dart';
import '../models/trade.dart';
import 'package:intl/intl.dart';

class TradingRecordsListWidget extends StatelessWidget {
  final List<Trade> trades;
  final ScrollController? scrollController;

  const TradingRecordsListWidget({
    Key? key,
    required this.trades,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(42),
          topRight: Radius.circular(42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 드래그 핸들 추가
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // 거래 내역 목록
          Expanded(
            child: trades.isEmpty ? _buildEmptyState() : _buildTradesList(),
          ),
        ],
      ),
    );
  }

  // 거래 내역이 없을 때 표시할 위젯
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          '거래 내역이 없어요',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // 거래 내역 목록을 표시할 위젯
  Widget _buildTradesList() {
    // 날짜별로 거래 내역 그룹화
    final groupedTrades = _groupTradesByDate();
    final dates = groupedTrades.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(left: 30, right: 30),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dailyTrades = groupedTrades[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff686767),
                ),
              ),
            ),
            ...List.generate(dailyTrades.length * 2 - 1, (index) {
              // 짝수 인덱스는 tradeCard, 홀수 인덱스는 Divider
              if (index % 2 == 0) {
                return tradeCard(dailyTrades[index ~/ 2]);
              } else {
                return const Divider(
                    height: 1, thickness: 1, color: Color(0xffF0EDFD));
              }
            }),
          ],
        );
      },
    );
  }

  Widget tradeCard(Trade trade) {
    // decision에 따른 색상 설정
    Color decisionColor;
    Color reasonColor;
    if (trade.decision == 'buy') {
      decisionColor = const Color(0xFFD7F8E4);
      reasonColor = const Color(0xFF4EC57E);
    } else if (trade.decision == 'sell') {
      decisionColor = const Color(0xFFD7EDF8);
      reasonColor = Color.fromARGB(255, 85, 152, 224);
    } else if (trade.decision == 'hold') {
      decisionColor = Color.fromARGB(255, 222, 224, 240);
      reasonColor = const Color(0xFF808199);
    } else {
      decisionColor = Colors.grey; // 기본값
      reasonColor = Colors.grey; // 기본값
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      // color: Colors.grey[200],
      height: 65,
      child: Row(
        children: [
          // decision
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: decisionColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset('assets/${trade.decision}_img.png'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trade.decision.toString(),
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              color: decisionColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 4, bottom: 2),
                              child: Text(
                                trade.reason.toString(), 
                                style: TextStyle(color: reasonColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))),
                    const SizedBox(width: 18),
                    Text(
                      trade.getFormattedTime(),
                      style: TextStyle(fontSize: 14, color: Color(0xff848484)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⇧ ${trade.getFormattedPrice()} 억',
                      style: TextStyle(fontSize: 16, color: Color(0xff848484)),
                    ),
                    Text(
                      '😄',
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 날짜별로 거래 내역 그룹화하는 함수
  Map<String, List<Trade>> _groupTradesByDate() {
    final groupedTrades = <String, List<Trade>>{};
    final now = DateTime.now();

    for (var trade in trades) {
      if (trade.timestamp == null) continue;

      final date = DateTime.parse(trade.timestamp!);
      String dateStr;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateStr = '오늘';
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        dateStr = '어제';
      } else {
        dateStr = DateFormat('yyyy년 M월 d일').format(date);
      }

      if (!groupedTrades.containsKey(dateStr)) {
        groupedTrades[dateStr] = [];
      }
      groupedTrades[dateStr]!.add(trade);
    }

    return groupedTrades;
  }
}
