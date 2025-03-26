import 'package:flutter/material.dart';
import 'package:gpt_coin_trading/widgets/wallet_info_widget.dart';
import '../models/trade.dart';
import '../widgets/trading_line_graph_widget.dart';
import '../widgets/trading_records_list_widget.dart';
import 'package:animated_background/animated_background.dart';
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

class _TradesPageState extends State<TradesPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
        

          Container(
            width: MediaQuery.of(context).size.width,
            child: AnimatedBackground(
              behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
                  spawnMaxRadius: 40,
                  spawnMinSpeed: 15,
                  particleCount: 20,
                  spawnMaxSpeed: 50,
                  spawnOpacity: 0.2,
                  baseColor: Colors.blue,
                  image: Image.asset('assets/icons/money.png'),
                )
              ),
              child: Center(child: Text(''),),
              vsync: this,)
          ),




          // 배경에 그래프 위젯 배치
          TradingLineGraphWidget(trades: widget.trades),


          // const Text('공주라는걸\n잊지 않기_⭐️', style: TextStyle(fontSize: 50, fontFamily: '읏맨체', color: Color(0xccFF4AC1)),),

          // 지갑 정보 위젯
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: WalletInfoWidget(
              returnRate: widget.returnRate,
              seed: widget.seed,
              btcBalance: widget.btcBalance,
              krwBalance: widget.krwBalance,
              lastUpdated: widget.lastUpdated,
              isLoading: widget.isWalletLoading,
            ),
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
              return Container(
                decoration:const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -10),
                      blurRadius: 20,
                      spreadRadius: 0,
                      color: Color(0x0F000000), // 6% 투명도의 검정색
                    ),
                  ],
                ),
                child: TradingRecordsListWidget(
                  trades: widget.trades,
                  scrollController: scrollController,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  
}
