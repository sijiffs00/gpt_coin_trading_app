import 'package:http/http.dart' as http;
import 'dart:convert';

class UpbitService {
  static const String baseUrl = 'https://api.upbit.com/v1';

  static Future<List<List<num>>> getBitcoinPrices() async {
    try {
      print('업비트 BTC가격정보 API 호출 시작 ...');
      
      final response = await http.get(
        Uri.parse(
          '$baseUrl/candles/days'
          '?market=KRW-BTC'
          '&count=150'
          '&fields=candle_date_time_utc,trade_price'
        ),
      );

      print('상태코드 : ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // 데이터의 시작일과 종료일 계산
        final firstDate = DateTime.parse(data.last['candle_date_time_utc']);
        final lastDate = DateTime.parse(data.first['candle_date_time_utc']);
        final period = '${firstDate.year}.${firstDate.month}.${firstDate.day} ~ ${lastDate.year}.${lastDate.month}.${lastDate.day}';
        
        print('기간 : $period');
        print('데이터 갯수 : ${data.length}');
        print('성공여부 : ${response.statusCode == 200 ? "성공" : "실패"}');
        
        return data.map((candle) {
          return <num>[
            DateTime.parse(candle['candle_date_time_utc']).millisecondsSinceEpoch,
            candle['trade_price'],
          ];
        }).toList().cast<List<num>>();
      } else {
        print('성공여부 : 실패 (${response.statusCode})');
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('성공여부 : 실패 (${e.toString()})');
      rethrow;
    }
  }
} 