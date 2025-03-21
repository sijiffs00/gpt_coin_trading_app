import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'models/trade.dart';
import 'pages/trades_page.dart';
import 'main.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TradesPage(
              trades: trades,
              returnRate: returnRate,
              seed: seed,
              btcBalance: btcBalance,
              krwBalance: krwBalance,
              lastUpdated: lastUpdated,
              isWalletLoading: isWalletLoading,
            ) 
          
    );
  }
}



