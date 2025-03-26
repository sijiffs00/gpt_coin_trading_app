import 'package:flutter/material.dart';
import '../models/trade.dart';
import 'package:intl/intl.dart';
import 'trade_detail_popup.dart';

class TradingRecordsListWidget extends StatefulWidget {
  final List<Trade> trades;
  final ScrollController? scrollController;

  const TradingRecordsListWidget({
    Key? key,
    required this.trades,
    this.scrollController,
  }) : super(key: key);

  @override
  State<TradingRecordsListWidget> createState() => _TradingRecordsListWidgetState();
}

class _TradingRecordsListWidgetState extends State<TradingRecordsListWidget> {
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
            child: widget.trades.isEmpty ? _buildEmptyState() : _buildTradesList(),
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
      controller: widget.scrollController,
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
                  fontFamily: '나눔고딕체',
                  color: Color(0xff686767),
                ),
              ),
            ),
            ...dailyTrades.map((trade) {
              // decision에 따라 다른 카드 위젯 반환
              switch (trade.decision) {
                case 'buy':
                  return buyTradeCard(trade);
                case 'sell':
                  return sellTradeCard(trade);
                case 'hold':
                  return holdTradeCard(trade);
                default:
                  return buyTradeCard(trade); // 기본값
              }
            }).toList(),
          ],
        );
      },
    );
  }

  // Buy 결정에 대한 카드 위젯
  Widget buyTradeCard(Trade trade) {
    return GestureDetector(
      onTap: () => _showTradeDetail(context, trade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 91,
        width: double.infinity,
        decoration:const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/buy.JPG'),
            fit: BoxFit.cover,
          ),
        ),
        child:  Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/balloon_buy.png', width: 220, height: 108,fit: BoxFit.cover,),
            const Text('사야지',
            style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff111111),
                        fontFamily: '읏맨체'),
            )
          ],
        ),
      ),
    );
  }

  // Sell 결정에 대한 카드 위젯
  Widget sellTradeCard(Trade trade) {
    return GestureDetector(
      onTap: () => _showTradeDetail(context, trade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 91,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/sell.JPG'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                Image.asset('assets/balloon_sell.png'),
                const Positioned(
                  top: 18,
                  left: 35,
                  child: Text(
                    '던져',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff111111),
                        fontFamily: '읏맨체'),
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/card_sell.png',
              height: 91,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  // Hold 결정에 대한 카드 위젯
  Widget holdTradeCard(Trade trade) {
    return GestureDetector(
      onTap: () => _showTradeDetail(context, trade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 91,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/hold.JPG'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Image.asset('assets/card_hold.png'),
            Stack(
              children: [
                Image.asset('assets/balloon_hold.png'),
                Positioned(
                  top: 15,
                  left: 22,
                  child: Text(
                    '홀드',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff111111),
                        fontFamily: '읏맨체'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 거래 상세 정보 팝업을 표시하는 함수
  void _showTradeDetail(BuildContext context, Trade trade) {
    showDialog(
      context: context,
      builder: (context) => TradeDetailPopup(trade: trade),
    );
  }

  // 날짜별로 거래 내역 그룹화하는 함수
  Map<String, List<Trade>> _groupTradesByDate() {
    final groupedTrades = <String, List<Trade>>{};
    final now = DateTime.now();

    for (var trade in widget.trades) {
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
