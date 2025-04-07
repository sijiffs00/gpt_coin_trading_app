import 'package:flutter/material.dart';

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
              _buildInfoItem('수익률', '${walletData['return_rate'] ?? 0}%'),
              _buildInfoItem('초기자본', '${_formatNumber(walletData['seed'])}원'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('BTC 보유량', '${_formatNumber(walletData['btc_balance'], decimals: 8)} BTC'),
              _buildInfoItem('KRW 보유량', '${_formatNumber(walletData['krw_balance'])}원'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '마지막 업데이트: ${walletData['last_updated'] ?? '정보 없음'}',
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

  String _formatNumber(dynamic value, {int decimals = 0}) {
    if (value == null) return '0';
    
    try {
      if (value is int) {
        return value.toStringAsFixed(decimals);
      } else if (value is double) {
        return value.toStringAsFixed(decimals);
      } else if (value is String) {
        return double.tryParse(value)?.toStringAsFixed(decimals) ?? '0';
      }
      return '0';
    } catch (e) {
      print('숫자 변환 에러: $e');
      return '0';
    }
  }
} 