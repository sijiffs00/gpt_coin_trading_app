import 'package:flutter/material.dart';
import '../models/trade.dart';
import 'package:fl_chart/fl_chart.dart';

class TradingLineGraphWidget extends StatelessWidget {
  final List<Trade> trades;

  const TradingLineGraphWidget({
    Key? key,
    required this.trades,
  }) : super(key: key);

  // 날짜 형식을 변환하는 함수 (02.28 -> 2/28 또는 같은 월이면 28)
  String formatDateWithoutLeadingZeros(DateTime dateTime, {DateTime? previousDate}) {
    final month = dateTime.month.toString();
    final day = dateTime.day.toString();
    
    // 이전 날짜가 없거나 월이 다르면 월/일 형식으로 표시
    if (previousDate == null || previousDate.month != dateTime.month) {
      return '$month/$day';
    } else {
      // 같은 월이면 일만 표시
      return day;
    }
  }

  // AM/PM 시간 형식으로 변환하는 함수
  String formatAMPMTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final ampm = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$ampm $hour12:$minute';
  }

  // decision에 따른 이모지와 텍스트를 반환하는 함수
  String _getDecisionEmoji(String? decision) {
    switch (decision) {
      case 'buy':
        return '💚 buy';
      case 'sell':
        return '💙 sell';
      case 'hold':
        return '🩶 hold';
      default:
        return '❓ unknown';
    }
  }

  // BTC 가격을 억 단위로 변환하는 함수
  String formatPriceInBillions(double? price) {
    if (price == null) return '0 억';
    return '${(price / 100000000).toStringAsFixed(3)} 억';
  }

  @override
  Widget build(BuildContext context) {
    // 데이터가 없을 경우 처리
    if (trades.isEmpty) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(
          child: Text(
            '아직 거래 데이터가 없어요!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'GowunDodum',
            ),
          ),
        ),
      );
    }

    // 차트에 사용할 데이터 준비하기
    final List<FlSpot> spots = [];
    
    // 시간순으로 정렬 (timestamp가 있는 경우만)
    final sortedTrades = [...trades]
      ..sort((a, b) {
        if (a.timestamp == null || b.timestamp == null) return 0;
        return DateTime.parse(a.timestamp!).compareTo(DateTime.parse(b.timestamp!));
      });
    
    // 차트 데이터 생성
    for (int i = 0; i < sortedTrades.length; i++) {
      final trade = sortedTrades[i];
      if (trade.price != null) {
        // x축은 인덱스, y축은 가격
        spots.add(FlSpot(i.toDouble(), trade.price! / 100000000)); // 비트코인 가격 단위 변환
      }
    }

    // 날짜 표시를 위한 준비
    // 각 날짜별 첫 번째 인덱스를 저장
    final Map<String, int> dateFirstIndices = {};
    for (int i = 0; i < sortedTrades.length; i++) {
      if (sortedTrades[i].timestamp != null) {
        final dateTime = DateTime.parse(sortedTrades[i].timestamp!);
        final dateStr = formatDateWithoutLeadingZeros(dateTime);
        if (!dateFirstIndices.containsKey(dateStr)) {
          dateFirstIndices[dateStr] = i;
        }
      }
    }

    // 날짜 라벨 위치 계산 (균등하게 분포)
    final List<int> dateIndices = dateFirstIndices.values.toList()..sort();
    
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
   
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 20.0, bottom: 12.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: false, // 격자선 숨기기
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        interval: 1, // 모든 눈금에 대해 체크
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          
                          // 날짜가 바뀌는 첫 지점에서만 날짜 표시
                          if (dateIndices.contains(index)) {
                            if (index >= 0 && index < sortedTrades.length && sortedTrades[index].timestamp != null) {
                              final dateTime = DateTime.parse(sortedTrades[index].timestamp!);
                              
                              // 이전 날짜 찾기 (있는 경우)
                              DateTime? previousDate;
                              final previousIndex = dateIndices.indexOf(index) - 1;
                              if (previousIndex >= 0 && previousIndex < dateIndices.length) {
                                final prevTradeIndex = dateIndices[previousIndex];
                                if (prevTradeIndex >= 0 && prevTradeIndex < sortedTrades.length && sortedTrades[prevTradeIndex].timestamp != null) {
                                  previousDate = DateTime.parse(sortedTrades[prevTradeIndex].timestamp!);
                                }
                              }
                              
                              final dateStr = formatDateWithoutLeadingZeros(dateTime, previousDate: previousDate);
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // y축 라벨 숨기기
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false, // 테두리 숨기기
                  ),
                  minX: 0,
                  maxX: spots.length - 1.0,
                  minY: spots.isEmpty ? 0 : spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.95,
                  maxY: spots.isEmpty ? 1 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.05,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Color(0xffD8CFFF),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true, // 점 보이기로 변경
                        getDotPainter: (spot, percent, barData, index) {
                          // decision에 따라 색상 결정
                          final trade = sortedTrades[index];
                          Color dotColor;
                          switch (trade.decision) {
                            case 'buy':
                              dotColor = Colors.green;
                              break;
                            case 'sell':
                              dotColor = Colors.blue;
                              break;
                            case 'hold':
                              dotColor = Colors.grey;
                              break;
                            default:
                              dotColor = Colors.grey;
                          }
                          return FlDotCirclePainter(
                            radius: 3, // 점 크기
                            color: dotColor.withOpacity(0.8),
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.white.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final int index = spot.x.toInt();
                          if (index >= 0 && index < sortedTrades.length) {
                            final trade = sortedTrades[index];
                            if (trade.timestamp != null) {
                              final dateTime = DateTime.parse(trade.timestamp!);
                              final dateStr = formatDateWithoutLeadingZeros(dateTime);
                              final timeStr = formatAMPMTime(dateTime);
                              return LineTooltipItem(
                                '$dateStr $timeStr\n${formatPriceInBillions(trade.price)}\n${_getDecisionEmoji(trade.decision)}',
                                const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                              );
                            }
                            return LineTooltipItem(
                              '${formatPriceInBillions(trade.price)}\n${_getDecisionEmoji(trade.decision)}',
                              const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        final trade = sortedTrades[spotIndex];
                        Color indicatorColor;
                        switch (trade.decision) {
                          case 'buy':
                            indicatorColor = Colors.green;
                            break;
                          case 'sell':
                            indicatorColor = Colors.blue;
                            break;
                          case 'hold':
                            indicatorColor = Colors.grey;
                            break;
                          default:
                            indicatorColor = Colors.grey;
                        }
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: indicatorColor.withOpacity(0.2),
                            strokeWidth: 2,
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: indicatorColor.withOpacity(0.8),
                                strokeWidth: 0,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 