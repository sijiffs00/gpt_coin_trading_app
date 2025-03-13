import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/trading_line_graph_widget.dart';
import '../widgets/trading_records_list_widget.dart';

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
      body: Stack(
        children: [
          // 배경에 그래프 위젯 배치
          TradingLineGraphWidget(trades: widget.trades),
          
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
}