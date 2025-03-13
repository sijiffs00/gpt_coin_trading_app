import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/trading_line_graph_widget.dart';
import '../widgets/trading_records_list_widget.dart';
import 'package:intl/intl.dart';

class TradesPage extends StatefulWidget {
  // trades 데이터를 받을 수 있도록 생성자 수정
  final List<Trade> trades;
  
  // 지갑 정보 변수들 추가
  final double returnRate;
  final int seed;
  final double btcBalance;
  final double krwBalance;
  final String lastUpdated;
  final bool isWalletLoading;
  
  const TradesPage({
    super.key,
    required this.trades,
    required this.returnRate,
    required this.seed,
    required this.btcBalance,
    required this.krwBalance,
    required this.lastUpdated,
    required this.isWalletLoading,
  });

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경에 그래프 위젯 배치
          TradingLineGraphWidget(trades: widget.trades),
          
          // 지갑 정보 위젯 추가
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildWalletInfoWidget(),
          ),
          
          // DraggableScrollableSheet로 스크롤 가능한 위젯 구현
          DraggableScrollableSheet(
            // 초기에는 화면의 절반만 차지
            initialChildSize: 0.5,
            // 최소 크기는 화면의 20%
            minChildSize: 0.2,
            // 최대 크기는 화면의 90%
            maxChildSize: 0.9,
            // 스크롤 컨트롤러 생성
            builder: (BuildContext context, ScrollController scrollController) {
              return TradingRecordsListWidget(
                trades: widget.trades,
                scrollController: scrollController,
              );
            },
          ),
        ],
      ),
    );
  }
  
  // 지갑 정보를 보여주는 위젯
  Widget _buildWalletInfoWidget() {
    final numberFormat = NumberFormat('#,###');
    
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10, 
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: widget.isWalletLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👛 내 지갑',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('수익률: ${widget.returnRate.toStringAsFixed(2)}%'),
                  Text('시드머니: ${numberFormat.format(widget.seed)}원'),
                  Text('BTC 잔액: ${widget.btcBalance.toStringAsFixed(8)} BTC'),
                  Text('원화 잔액: ${numberFormat.format(widget.krwBalance)}원'),
                  Text('마지막 업데이트: ${widget.lastUpdated}'),
                ],
              ),
            ),
    );
  }
}