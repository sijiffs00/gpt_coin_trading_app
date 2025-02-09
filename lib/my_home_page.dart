import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 패키지 import
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'widgets/trade_card.dart';  // 새로 추가!

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Trade> trades = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTrades();
  }

  Future<void> fetchTrades() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://15.164.48.123:8000/api/trades'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            trades = (data['trades'] as List)
                .map((trade) => Trade.fromJson(trade))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching trades: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비트코인 차트'),
        elevation: 8,
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trades.isEmpty
              ? const Center(child: Text('데이터가 없습니다'))
              : ListView.builder(
                  itemCount: trades.length,
                  itemBuilder: (context, index) => TradeCard(trade: trades[index]),
                ),
    );
  }
}
