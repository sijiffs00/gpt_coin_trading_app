import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../main.dart';

class MyWalletWidget extends StatefulWidget {
  const MyWalletWidget({super.key});

  @override
  State<MyWalletWidget> createState() => _MyWalletWidgetState();
}

class _MyWalletWidgetState extends State<MyWalletWidget> {
  double returnRate = 0;
  int seed = 0;
  double btcBalance = 0;
  double krwBalance = 0;
  String lastUpdated = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWalletInfo();
  }

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
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('지갑 정보 가져오기 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: MediaQuery.of(context).size.width,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👛 내 지갑',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('수익률: ${returnRate.toStringAsFixed(2)}%'),
                  Text('시드머니: ${numberFormat.format(seed)}원'),
                  Text('BTC 잔액: ${btcBalance.toStringAsFixed(8)} BTC'),
                  Text('원화 잔액: ${numberFormat.format(krwBalance)}원'),
                  Text('마지막 업데이트: $lastUpdated'),
                ],
              ),
            ),
    );
  }
} 