import 'package:http/http.dart' as http;
import 'dart:convert';

class UpbitService {
  static const String baseUrl = 'https://api.upbit.com/v1';

  static Future<List<List<num>>> getBitcoinPrices() async {
    try {
      // 현재 시간을 KST(한국 시간)로 변환
      final now = DateTime.now();
      final to = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
      
      // 200일 전 데이터부터 요청
      final from = to - (200 * 24 * 60 * 60);

      final url = Uri.parse(
        'https://api.upbit.com/v1/candles/days'
        '?market=KRW-BTC'
        '&count=200'
      );  // to와 from 파라미터는 제거

      print('요청 URL: $url'); // URL 확인

      final response = await http.get(url);
      print('응답 상태 코드: ${response.statusCode}'); // 상태 코드 확인
      // print('응답 내용: ${response.body}'); // 응답 데이터 확인

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // 데이터 변환 전 확인
        // print('파싱된 데이터: $data');
        
        return data.map<List<num>>((item) {
          final timestamp = DateTime.parse(item['candle_date_time_utc'] + 'Z')
              .millisecondsSinceEpoch.toDouble();
          final closePrice = (item['trade_price'] as num).toDouble();
          return [timestamp, closePrice];
        }).toList();
      }
      return [];
    } catch (e) {
      print('비트코인 가격 데이터 로딩 실패: $e'); // 에러 상세 내용 확인
      return [];
    }
  }
} 