import 'package:flutter/material.dart';
import 'package:gpt_coin_trading/widgets/custom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'models/trade.dart';
import 'pages/trades_page.dart';
import 'pages/graph_page.dart';
import 'main.dart'; 
import 'package:fl_chart/fl_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 현재 선택된 탭 인덱스를 저장하는 변수
  int _selectedIndex = 0;

  // 거래 데이터와 BTC 가격 데이터
  List<Trade> trades = [];
  List<FlSpot> btcPrices = [];

  @override
  void initState() {
    super.initState();
    // 앱 시작시 데이터 로드
    fetchData();
  }

  // 매매기록들 가져오기
  Future<void> fetchData() async {
    try {
      final tradesResponse = await http.get(Uri.parse('$serverUrl/api/trades'));
      if (tradesResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(tradesResponse.body);
        if (data['success'] == true) {
          
          setState(() {
            trades = (data['trades'] as List)
                .map((trade) => Trade.fromJson(trade))
                .toList();
          });
          
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // 탭 변경 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 탭에 따라 표시할 화면 목록
  List<Widget> _getPages() {
    return [
      TradesPage(trades: trades), // TradesPage에도 trades 데이터 전달
      GraphPage(trades: trades), // GraphPage에는 데이터 전달
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
 
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: pages[_selectedIndex],
    );
  }
}



