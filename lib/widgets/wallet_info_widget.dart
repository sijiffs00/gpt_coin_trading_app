import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletInfoWidget extends StatelessWidget {
  // 지갑 정보에 필요한 속성들 정의
  final double returnRate;
  final int seed;
  final double btcBalance;
  final double krwBalance;
  final String lastUpdated;
  final bool isLoading;

  // 생성자에서 필요한 모든 속성 값을 받음
  const WalletInfoWidget({
    super.key,
    required this.returnRate,
    required this.seed,
    required this.btcBalance,
    required this.krwBalance,
    required this.lastUpdated,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // 숫자 포맷 설정 (천 단위 구분 기호 추가)
    final numberFormat = NumberFormat('#,###');

    return Container(
      width: MediaQuery.of(context).size.width,
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