import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 패키지 import
import 'dart:convert'; // JSON 처리를 위한 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비트코인 차트')),
      body: buildChartList(),
    );
  }


// 차트 이미지 목록 가져오기
Future<List<ChartImage>> getChartImages() async {
  try {
    print('API 요청 시작: http://15.164.48.123:8000/api/charts');
    final response = await http.get(Uri.parse('http://15.164.48.123:8000/api/charts'));
    print('API 응답 상태 코드: ${response.statusCode}');
    print('API 응답 내용: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> charts = data['charts'];
        return charts.map((chart) => ChartImage.fromJson(chart)).toList();
      } else {
        print('API 응답 실패: ${data['message'] ?? '알 수 없는 에러'}');
        throw Exception('API 응답이 실패했습니다.');
      }
    } else {
      print('서버 에러 발생: ${response.statusCode}');
      print('에러 응답 내용: ${response.body}');
      throw Exception('서버 에러: ${response.statusCode}');
    }
  } catch (e) {
    print('예외 발생: $e');
    throw Exception('차트 이미지를 가져오는데 실패했습니다: $e');
  }
}

// UI에서 이미지 표시하기 (예시)
Widget buildChartList() {
  return FutureBuilder<List<ChartImage>>(
    future: getChartImages(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(child: Text('에러: ${snapshot.error}'));
      }
      
      final charts = snapshot.data!;
      
      return ListView.builder(
        itemCount: charts.length,
        itemBuilder: (context, index) {
          final chart = charts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image.memory(
                  base64Decode(chart.imageData),
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${chart.filename}\n${chart.lastModified.toString()}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}  
}

class ChartImage {
  final String filename;
  final String imageData;
  final DateTime lastModified;

  ChartImage({
    required this.filename,
    required this.imageData,
    required this.lastModified,
  });

  factory ChartImage.fromJson(Map<String, dynamic> json) {
    return ChartImage(
      filename: json['filename'],
      imageData: json['image_data'],
      lastModified: DateTime.parse(json['last_modified']),
    );
  }
}
