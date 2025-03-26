import 'package:flutter/material.dart';
import '../models/trade.dart';
import 'package:intl/intl.dart';

class TradeDetailPopup extends StatelessWidget {
  final Trade trade;

  const TradeDetailPopup({
    Key? key,
    required this.trade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDecisionText(trade.decision),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getDecisionColor(trade.decision),
                    fontFamily: '읏맨체',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 거래 정보
            _buildInfoRow('시간', _formatDateTime(trade.timestamp)),
            _buildInfoRow('가격', '${NumberFormat('#,###').format(trade.price)}원'),
            if (trade.amount != null) _buildInfoRow('수량', '${trade.amount} BTC'),
            if (trade.total != null) _buildInfoRow('총액', '${NumberFormat('#,###').format(trade.total)}원'),
            if (trade.reason != null) _buildInfoRow('이유', trade.reason!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: null,  // 여러 줄 허용
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return '알 수 없음';
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy년 M월 d일 HH:mm').format(dateTime);
  }

  String _getDecisionText(String? decision) {
    switch (decision) {
      case 'buy':
        return 'Buy';
      case 'sell':
        return 'Sell';
      case 'hold':
        return 'Hold';
      default:
        return '알 수 없음';
    }
  }

  Color _getDecisionColor(String? decision) {
    switch (decision) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.blue;
      case 'hold':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
} 