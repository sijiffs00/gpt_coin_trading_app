import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../widgets/trading_line_graph_widget.dart';
import '../widgets/trading_records_list_widget.dart';
import 'package:animated_background/animated_background.dart';

class TradesPage extends StatefulWidget {
  final List<Trade> trades;

  const TradesPage({
    super.key,
    required this.trades,
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

          // DraggableScrollableSheet로 스크롤 가능한 위젯 구현
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.9,
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
                      color: Color(0x0F000000),
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
