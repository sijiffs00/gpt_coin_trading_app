import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'package:intl/intl.dart';
import 'pages/trades_page.dart';
import 'pages/graph_page.dart';
import 'main.dart'; // serverUrl 사용을 위한 import
import 'services/upbit_service.dart';
import 'package:fl_chart/fl_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// LoadingStatus enum 추가
enum LoadingStatus { loading, success, empty, error }

class _MyHomePageState extends State<MyHomePage> {
  List<Trade> trades = [];
  List<FlSpot> btcPrices = [];
  LoadingStatus loadingStatus = LoadingStatus.loading;
  int _selectedIndex = 0;

  // 그래프 페이지를 캐시하기 위한 변수
  late final GraphPage _graphPage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        fetchTrades(),
        fetchBtcPricesData(),
      ]);

      _graphPage = GraphPage(
        trades: trades,
        btcPrices: btcPrices,
      );
    } catch (e) {
      print('데이터 초기화 실패: $e');
      setState(() {
        loadingStatus = LoadingStatus.error;
      });
    }
  }

  Future<void> fetchTrades() async {
    setState(() {
      loadingStatus = LoadingStatus.loading;
    });

    try {
      // 새로운 API 엔드포인트로 변경
      final response = await http.get(Uri.parse('$serverUrl/api/trades'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final tradesList = (data['trades'] as List)
              .map((trade) => Trade.fromJson(trade))
              .toList();

          setState(() {
            trades = tradesList;
            loadingStatus = tradesList.isEmpty
                ? LoadingStatus.empty
                : LoadingStatus.success;
          });
        }
      }
    } catch (e) {
      print('Error fetching trades: $e');
      setState(() {
        loadingStatus = LoadingStatus.error;
      });
    }
  }

  // 비트코인 가격 데이터 가져오기 -> FLSpot 객체로 변환
  Future<void> fetchBtcPricesData() async {
    try {
      final prices = await UpbitService.getBitcoinPrices();
      if (prices.isEmpty) return;

      prices.sort((a, b) => a[0].compareTo(b[0]));

      final spots = prices.asMap().entries.map((entry) {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(prices[entry.key][0].toInt());
        final firstTimestamp =
            DateTime.fromMillisecondsSinceEpoch(prices[0][0].toInt());
        final daysDifference =
            timestamp.difference(firstTimestamp).inDays.toDouble();

        final priceInWon = prices[entry.key][1].toDouble();
        return FlSpot(daysDifference, priceInWon);
      }).toList();

      if (mounted) {
        setState(() {
          btcPrices = spots;
        });
      }
    } catch (e) {
      print('비트코인 가격 데이터 로딩 실패: $e');
    }
  }

  // 거래 내역을 날짜별로 그룹화하는 함수
  Map<String, List<Trade>> groupTradesByDate() {
    final groupedTrades = <String, List<Trade>>{};
    final now = DateTime.now();

    for (var trade in trades) {
      if (trade.timestamp == null) continue;

      final date = DateTime.parse(trade.timestamp!);
      String dateStr;

      // 오늘인지 확인
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateStr = '오늘';
      }
      // 어제인지 확인
      else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        dateStr = '어제';
      }
      // 그 외의 날짜
      else {
        dateStr = DateFormat('yyyy년 M월 d일').format(date);
      }

      if (!groupedTrades.containsKey(dateStr)) {
        groupedTrades[dateStr] = [];
      }
      groupedTrades[dateStr]!.add(trade);
    }

    return groupedTrades;
  }

  @override
  Widget build(BuildContext context) {
    // 서버 종류를 확인하는 문자열을 만들어줄게
    String serverType = serverUrl.contains('172.30') ? '🏠로컬' : '🔋EC2';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serverType, // 여기에 서버 종류를 표시해줄거야
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
              Image.asset(
                'assets/dance.gif',
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
          elevation: 8,
          shadowColor: Colors.black38,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      body: _selectedIndex == 0
          ? const TradesPage()
          : loadingStatus == LoadingStatus.error
              ? Container(
                  // Container로 감싸서 배경색 지정
                  color: Colors.white, // 배경색을 흰색으로 설정
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '서버 연결이 안된다고',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF666666)),
                      ),
                      SizedBox(height: 14),
                      Image.asset(
                        'assets/angry_gom.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      InkWell(
                        onTap: _initializeApp,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 237, 237, 239),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text('재시도',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B3C51))),
                        ),
                      )
                    ],
                  )),
                )
              : _graphPage,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: '매매기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: '그래프',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFA177FF),
        unselectedItemColor: const Color(0xFF868697),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
