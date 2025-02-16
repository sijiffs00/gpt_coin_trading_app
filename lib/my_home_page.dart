import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; // JSON 처리를 위한 import
import 'models/trade.dart';
import 'widgets/trade_card.dart';  
import 'pages/trade_detail_page.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Colors.white,     
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
        final groupedTrades = groupTradesByDate();
        final dates = groupedTrades.keys.toList()..sort((a, b) => b.compareTo(a));  // 최신 날짜순

        return RefreshIndicator(
          onRefresh: fetchTrades,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dailyTrades = groupedTrades[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                  ...dailyTrades.map((trade) => TradeCard(
                    trade: trade,
                    onTap: (trade) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TradeDetailPage(trade: trade),
                        ),
                      );
                    },
                  )).toList(),
                ],
              );
            },
          ),
        );
    }
  }
}
