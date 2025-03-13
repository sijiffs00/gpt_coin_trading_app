import 'package:flutter/material.dart';
import '../models/trade.dart';

class RecordsWidget extends StatelessWidget {
  final List<Trade> trades;

  const RecordsWidget({
    Key? key,
    required this.trades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: trades.isEmpty
          ? const Center(
              child: Text(
                '거래 기록이 없어요',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2.0,
                  child: ListTile(
                    leading: Icon(
                      trade.decision == 'buy' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: trade.decision == 'buy' ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      '${trade.decision == 'buy' ? '매수' : '매도'} - ${trade.price} 원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '날짜: ${trade.timestamp ?? "날짜 정보 없음"}\n이유: ${trade.reason ?? "이유 정보 없음"}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
} 