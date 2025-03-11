import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trade.dart';
import '../widgets/trade_card.dart';
import '../pages/trade_detail_page.dart';
import 'package:intl/intl.dart';
import '../main.dart';  // serverUrl 사용을 위한 import


class TradesPage extends StatefulWidget {
  // trades 데이터를 받을 수 있도록 생성자 수정
  final List<Trade> trades;
  
  const TradesPage({
    super.key,
    required this.trades,
  });

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 그라데이션 배경 적용
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0C3FC),  // 연한 보라색
              Color(0xFF8EC5FC),  // 연한 파란색
            ],
          ),
        ),
        child: widget.trades.isEmpty
            ? _buildEmptyState()
            : _buildTradesList(),
      ),
    );
  }
  
  // 거래 내역이 없을 때 표시할 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '거래 내역이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/die_gom.png',  // 이미지가 있다면 사용
            width: 200,
            height: 200,
          ),
        ],
      ),
    );
  }
  
  // 거래 내역 목록을 표시할 위젯
  Widget _buildTradesList() {
    // 날짜별로 거래 내역 그룹화
    final groupedTrades = _groupTradesByDate();
    final dates = groupedTrades.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...dailyTrades.map((trade) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  trade.decision == 'buy' ? '매수' : '매도',
                  style: TextStyle(
                    color: trade.decision == 'buy' ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${NumberFormat('#,###').format(trade.price ?? 0)} 원',
                ),
                trailing: Text(
                  trade.timestamp != null
                      ? DateFormat('HH:mm').format(DateTime.parse(trade.timestamp!))
                      : '',
                ),
                onTap: () {
                  // 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TradeDetailPage(trade: trade),
                    ),
                  );
                },
              ),
            )),
          ],
        );
      },
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
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateStr = '오늘';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
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