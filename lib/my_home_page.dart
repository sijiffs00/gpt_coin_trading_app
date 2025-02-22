import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'widgets/trade_card.dart';  
import 'pages/trade_detail_page.dart';
import 'package:intl/intl.dart';
import 'pages/trades_page.dart';
import 'pages/graph_page.dart';

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
  LoadingStatus loadingStatus = LoadingStatus.loading;
  int _selectedIndex = 0;
  
  // GraphPage에 trades 데이터를 전달하도록 수정
  final List<Widget> _pages = [];  // 초기화를 build에서 할거야

  @override
  void initState() {
    super.initState();
    fetchTrades();  // 그래프용 데이터를 가져오기
  }

  Future<void> fetchTrades() async {
    setState(() {
      loadingStatus = LoadingStatus.loading;
    });

    try {
      // 새로운 API 엔드포인트로 변경
      final response = await http.get(Uri.parse('http://15.164.48.123:8000/api/trades'));
      
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
    // 여기서 _pages를 초기화해서 trades 데이터를 전달
    _pages.clear();  // 기존 항목들 제거
    _pages.addAll([
      const TradesPage(),  // TradesPage는 자체적으로 데이터를 가져오니까 그대로 둬
      GraphPage(trades: trades),  // GraphPage에 trades 데이터 전달
    ]);

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
      body: _pages[_selectedIndex],  // 선택된 페이지 표시
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
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
