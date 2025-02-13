import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'widgets/trade_card.dart';  
import 'pages/trade_detail_page.dart';

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
  // isLoading 대신 loadingStatus 사용
  LoadingStatus loadingStatus = LoadingStatus.loading;

  @override
  void initState() {
    super.initState();
    fetchTrades();
  }

  Future<void> fetchTrades() async {
    setState(() {
      loadingStatus = LoadingStatus.loading;
    });

    try {
      final response = await http.get(Uri.parse('http://15.164.48.123:8000/api/trades'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final tradesList = (data['trades'] as List)
              .map((trade) => Trade.fromJson(trade))
              .toList();
          
          setState(() {
            trades = tradesList;
            // 데이터가 있는지 없는지에 따라 상태 설정
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),  // AppBar 높이를 80으로 설정
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,  // GIF를 중앙에 배치
            children: [
              Image.asset(
                'assets/dance.gif',
                height: 60,  // GIF 크기를 60으로 키움
                fit: BoxFit.contain,
              ),
            ],
          ),
          elevation: 8,
          shadowColor: Colors.black38,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          centerTitle: true,  // title을 중앙 정렬
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F6),  // 배경색 설정
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (loadingStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return const Center(
          child: Text(
            '현재 데이터가 없어요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      case LoadingStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '서버 꺼져있음',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchTrades,
                child: const Text('새로고침'),
              ),
            ],
          ),
        );
      case LoadingStatus.success:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            itemCount: trades.length,
            itemBuilder: (context, index) => TradeCard(
              trade: trades[index],
              onTap: (trade) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TradeDetailPage(trade: trade),
                  ),
                );
              },
            ),
          ),
        );
    }
  }
}
