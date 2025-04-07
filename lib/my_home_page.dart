import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'models/trade.dart';
import 'pages/trades_page.dart';
import 'main.dart'; 

// 업비트 지갑 정보를 보여주는 위젯
class UpbitWalletWidget extends StatelessWidget {
  final Map<String, dynamic> walletData;

  const UpbitWalletWidget({
    super.key,
    required this.walletData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '업비트 지갑',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('수익률', '${walletData['return_rate']}%'),
              _buildInfoItem('초기자본', '${walletData['seed'].toStringAsFixed(0)}원'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('BTC 보유량', '${walletData['btc_balance']} BTC'),
              _buildInfoItem('KRW 보유량', '${walletData['krw_balance'].toStringAsFixed(0)}원'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '마지막 업데이트: ${walletData['last_updated']}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // 거래 데이터
  List<Trade> trades = [];
  Map<String, dynamic> walletData = {};

  @override
  void initState() {
    super.initState();
    // 앱 시작시 데이터 로드
    fetchData();
    fetchUpbitWalletData();
  }

  // 업비트 지갑 데이터 가져오기
  Future<void> fetchUpbitWalletData() async {
    try {
      final walletResponse = await http.get(Uri.parse('$serverUrl/api/upbit_wallet'));
      final Map<String, dynamic> data = json.decode(walletResponse.body);
      
      if (walletResponse.statusCode == 200 && data['success'] == true) {
        setState(() {
          walletData = data['wallet'];
        });
      } else if (walletResponse.statusCode == 500) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('서버에서 지갑 정보를 가져오는데 실패했습니다. 잠시 후 다시 시도해주세요.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        print('서버 에러: ${walletResponse.statusCode} - ${walletResponse.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('Error fetching wallet data: $e');
    }
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
        walletData: walletData,
      ),
    );
  }
}



