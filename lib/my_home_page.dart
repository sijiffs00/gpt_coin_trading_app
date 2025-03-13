import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'models/trade.dart';
import 'widgets/trading_line_graph_widget.dart';
import 'widgets/records_widget.dart';
import 'widgets/custom_navigation_bar.dart';
import 'pages/graph_page.dart';
import 'pages/trades_page.dart';
import 'main.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 현재 선택된 탭 인덱스를 저장하는 변수
  int _selectedIndex = 0;
  
  // 거래 데이터
  List<Trade> trades = [];

  // 지갑 정보 변수들
  double returnRate = 0;
  int seed = 0;
  double btcBalance = 0;
  double krwBalance = 0;
  String lastUpdated = '';
  bool isWalletLoading = true;

  @override
  void initState() {
    super.initState();
    // 앱 시작시 데이터 로드
    fetchData();
    fetchWalletInfo(); // 지갑 정보도 함께 로드
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

  // 지갑 정보 가져오기
  Future<void> fetchWalletInfo() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/api/wallet'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final wallet = data['wallet'];
          setState(() {
            returnRate = (wallet['return_rate'] ?? 0).toDouble();
            seed = wallet['seed'] ?? 0;
            btcBalance = (wallet['btc_balance'] ?? 0).toDouble();
            krwBalance = (wallet['krw_balance'] ?? 0).toDouble();
            lastUpdated = wallet['last_updated'] ?? '';
            isWalletLoading = false;
          });
        }
      }
    } catch (e) {
      print('지갑 정보 가져오기 실패: $e');
      setState(() {
        isWalletLoading = false;
      });
    }
  }

  // 탭 변경 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: (_selectedIndex == 0) 
          ? TradesPage(
              trades: trades,
              returnRate: returnRate,
              seed: seed,
              btcBalance: btcBalance,
              krwBalance: krwBalance,
              lastUpdated: lastUpdated,
              isWalletLoading: isWalletLoading,
            ) 
          : GraphPage(trades: trades),
    );
  }
}



