import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gpt_coin_trading/my_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 서버 주소 설정
// const String serverUrl = 'http://172.30.1.6:8000';  // 맥북 로컬 
const String serverUrl = 'http://15.164.48.123:8000';  // EC2

// 백그라운드 메시지를 처리하는 함수야
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("백그라운드 메시지 도착!: ${message.messageId}");
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter Binding 초기화 완료');
    
    // Firebase 초기화를 여기서 먼저 해주자
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 완료');

    // 날짜 포맷 초기화도 여기서
    await initializeDateFormatting('ko_KR', null);
    print('날짜 포맷 초기화 완료');

    // FCM 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('FCM 백그라운드 핸들러 설정 완료');

    // 이제 앱 실행
    runApp(const MyApp());
    print('앱 실행 완료');
  } catch (e) {
    print('초기화 중 에러 발생: $e');
    runApp(const MyApp());
  }
}

// 로딩 화면 위젯을 별도로 분리
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/running_gom.gif',
              width: 300,  // GIF 크기 조절
              height: 300,
            ),
            const SizedBox(height: 16),

            Text(
              '가보자고',
              style: TextStyle(
                fontFamily: 'Tenada',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'LINESeedKR',  // 앱 전체 기본 폰트로 설정
      ),
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 초기화 중일 때 보여줄 로딩 화면
            return const LoadingScreen();
          }
          // 초기화가 완료되면 메인 화면으로!
          return const MyHomePage();
        },
      ),
    );
  }
}
// 앱 초기화 함수를 따로 만들어줄게
Future<void> _initializeApp() async {
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (Platform.isIOS) {
    for (int i = 0; i < 3; i++) {
      try {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          final token = await messaging.getToken();
          try {
            await http.post(
              Uri.parse('$serverUrl/api/fcm-token'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'token': token}),
            );
          } catch (e) {
            print('FCM 토큰 서버 전송 중 에러: $e');
          }
          break;
        }
      } catch (e) {
        print('토큰 처리 중 에러: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}

enum DataStatus { success, empty, error }

