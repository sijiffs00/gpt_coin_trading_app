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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TradesPage(
        trades: trades,
      ) 
    );
  }
}



