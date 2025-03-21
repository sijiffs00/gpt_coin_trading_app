import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/trading_line_graph_widget.dart';
import '../widgets/trading_records_list_widget.dart';
import '../widgets/wallet_info_widget.dart';
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
          
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Opacity(
                opacity: 0.5,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: FractionalTranslation(
                      translation: Offset(0.1, 0.2), // 이미지를 x,y 좌표 기준으로 이동시킴
                      child: Image.asset(
                        'assets/princess.png',
                        fit: BoxFit.none, // 이미지를 원본 크기로 유지
                        alignment: Alignment.topLeft, // 이미지가 왼쪽 상단을 기준으로 정렬되도록 설정
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 배경에 그래프 위젯 배치
          TradingLineGraphWidget(trades: widget.trades),


          Text('공주라는걸\n잊지 않기_⭐️', style: TextStyle(fontSize: 50, fontFamily: '읏맨체', color: Color(0xccFF4AC1)),),

          // 지갑 정보 위젯
          // Positioned(
          //   top: 50,
          //   left: 20,
          //   right: 20,
          //   child: WalletInfoWidget(
          //     returnRate: widget.returnRate,
          //     seed: widget.seed,
          //     btcBalance: widget.btcBalance,
          //     krwBalance: widget.krwBalance,
          //     lastUpdated: widget.lastUpdated,
          //     isLoading: widget.isWalletLoading,
          //   ),
          // ),

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
