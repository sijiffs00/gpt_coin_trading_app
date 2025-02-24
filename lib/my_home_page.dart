import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'package:intl/intl.dart';
import 'pages/trades_page.dart';
import 'pages/graph_page.dart';
import 'main.dart';  // serverUrl 사용을 위한 import
import 'services/upbit_service.dart';
import 'package:fl_chart/fl_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// LoadingStatus enum 추가
enum LoadingStatus {
  loading,
  success,
  empty,
  error
}

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
            loadingStatus = tradesList.isEmpty ? LoadingStatus.empty : LoadingStatus.success;
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

  // 비트코인 가격 데이터를 가져오는 함수 추가
  Future<void> fetchBtcPricesData() async {
    try {
      final prices = await UpbitService.getBitcoinPrices();
      if (prices.isEmpty) return;

      // List<List<num>>을 List<FlSpot>으로 변환
      final processedPrices = prices.map((price) {
        // timestamp를 월 단위로 변환 (예: 24.10)
        final date = DateTime.fromMillisecondsSinceEpoch(price[0].toInt());
        final xValue = date.year % 100 + (date.month / 12);
        return FlSpot(xValue, price[1].toDouble());
      }).toList();

      if (mounted) {
        setState(() {
          btcPrices = processedPrices;
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
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateStr = '오늘';
      }
      // 어제인지 확인
      else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('데이터를 불러오는데 실패했습니다 😢'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeApp,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
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
