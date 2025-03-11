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
  
  // 데이터 가져오기
  Future<void> fetchData() async {
    try {
      // 거래 데이터 가져오기
      final tradesResponse = await http.get(Uri.parse('$serverUrl/api/trades/recent'));
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
      
      // BTC 가격 데이터 가져오기
      final pricesResponse = await http.get(Uri.parse('$serverUrl/api/btc-prices'));
      if (pricesResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(pricesResponse.body);
        if (data['success'] == true) {
          final pricesList = data['prices'] as List;
          setState(() {
            btcPrices = List.generate(
              pricesList.length,
              (index) => FlSpot(
                index.toDouble(),
                (pricesList[index]['price'] as num).toDouble(),
              ),
            );
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
      const TradesPage(),  // TradesPage는 자체적으로 데이터를 가져옴
      GraphPage(trades: trades, btcPrices: btcPrices),  // GraphPage에는 데이터 전달
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    
    return Scaffold(
      // 하단 네비게이션 바 추가
      bottomNavigationBar: Container(
        // 상단 모서리 둥글게 처리 (왼쪽 상단, 오른쪽 상단만 둥글게)
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
            ),
          ],
        ),
        // ClipRRect로 감싸서 내부 위젯도 둥근 모서리 적용
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white, // 네비게이션바 배경색을 하얀색으로 설정
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: '매매기록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: '그래프',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.purple[200],
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        ),
      ),
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
        // 선택된 탭에 따라 다른 페이지 표시
        child: pages[_selectedIndex],
      ),
    );
  }
}