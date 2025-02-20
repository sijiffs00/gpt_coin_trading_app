import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trade.dart';
import '../widgets/trade_card.dart';
import '../pages/trade_detail_page.dart';
import 'package:intl/intl.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  List<Trade> trades = [];
  LoadingStatus loadingStatus = LoadingStatus.loading;
  bool isLoadingMore = false;
  DateTime? oldestLoadedDate;

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
      final response = await http.get(Uri.parse('http://15.164.48.123:8000/api/trades/recent'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final tradesList = (data['trades'] as List)
              .map((trade) => Trade.fromJson(trade))
              .toList();
          
          setState(() {
            trades = tradesList;
            if (tradesList.isNotEmpty) {
              oldestLoadedDate = DateTime.parse(tradesList.last.timestamp!);
            }
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

  Future<void> loadMoreTrades() async {
    if (isLoadingMore || oldestLoadedDate == null) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final previousDate = oldestLoadedDate!.subtract(const Duration(days: 1));
      final response = await http.get(
        Uri.parse('http://15.164.48.123:8000/api/trades/by-date?date=${previousDate.toString().split(' ')[0]}')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newTrades = (data['trades'] as List)
              .map((trade) => Trade.fromJson(trade))
              .toList();
          
          setState(() {
            trades.addAll(newTrades);
            if (newTrades.isNotEmpty) {
              oldestLoadedDate = previousDate;
            }
          });
        }
      }
    } catch (e) {
      print('Error loading more trades: $e');
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Map<String, List<Trade>> groupTradesByDate() {
    final groupedTrades = <String, List<Trade>>{};
    final now = DateTime.now();
    
    for (var trade in trades) {
      if (trade.timestamp == null) continue;
      
      final date = DateTime.parse(trade.timestamp!);
      String dateStr;
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateStr = '오늘';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        dateStr = '어제';
      } else {
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
      backgroundColor: Colors.white,     
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (loadingStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return const Center(child: Text('현재 데이터가 없어요'));
      case LoadingStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('서버 꺼져있음'),
              ElevatedButton(
                onPressed: fetchTrades,
                child: const Text('새로고침'),
              ),
            ],
          ),
        );
      case LoadingStatus.success:
        final groupedTrades = groupTradesByDate();
        final dates = groupedTrades.keys.toList()..sort((a, b) => b.compareTo(a));

        return RefreshIndicator(
          onRefresh: fetchTrades,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                loadMoreTrades();
              }
              return true;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dates.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == dates.length && isLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                final date = dates[index];
                final dailyTrades = groupedTrades[date]!;
                return _buildDateSection(date, dailyTrades);
              },
            ),
          ),
        );
    }
  }

  Widget _buildDateSection(String date, List<Trade> trades) {
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
        ...trades.map((trade) => TradeCard(
          trade: trade,
          onTap: (trade) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TradeDetailPage(trade: trade),
            ),
          ),
        )),
      ],
    );
  }
}

enum LoadingStatus {
  loading,
  success,
  empty,
  error
} 