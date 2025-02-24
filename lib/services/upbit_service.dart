import 'package:http/http.dart' as http;
import 'dart:convert';

class UpbitService {
  static const String baseUrl = 'https://api.upbit.com/v1';

  static Future<List<List<num>>> getBitcoinPrices() async {
    try {
      // 시작 날짜 설정 (2024년 10월 1일)
      final startDate = DateTime(2024, 10, 1);
      final now = DateTime.now();
      
      // 시작 시간과 현재 시간을 Unix timestamp(초 단위)로 변환
      final to = now.millisecondsSinceEpoch ~/ 1000;
      final from = startDate.millisecondsSinceEpoch ~/ 1000;

      final url = Uri.parse(
        'https://api.upbit.com/v1/candles/days'
        '?market=KRW-BTC'
        '&count=200'  // 최대 데이터 개수
        '&to=${to}'
        '&from=${from}'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // 종가(trade_price)와 시간(timestamp) 데이터만 추출
        return data.map<List<num>>((item) {
          final timestamp = DateTime.parse(item['candle_date_time_utc'] + 'Z')
              .millisecondsSinceEpoch.toDouble();
          final closePrice = (item['trade_price'] as num).toDouble();
          return [timestamp, closePrice];
        }).toList();
      }
      return [];
    } catch (e) {
      print('비트코인 가격 데이터 로딩 실패: $e');
      return [];
    }
  }
} 