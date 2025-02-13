import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gpt_coin_trading/my_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// 백그라운드 메시지를 처리하는 함수야
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("백그라운드 메시지 도착!: ${message.messageId}");
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter Binding 초기화 완료');
    
    await initializeDateFormatting('ko_KR', null);
    print('날짜 포맷팅 초기화 완료');
    
    // Firebase 초기화
    print('Firebase 초기화 시작...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 완료!');
    
    // 백그라운드 메시지 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('백그라운드 메시지 핸들러 설정 완료');
    
    // 알림 권한 요청
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('알림 권한 상태: ${settings.authorizationStatus}');
    
    if (Platform.isIOS) {
      print('iOS 디바이스 확인됨');
      // APNS 토큰을 여러 번 시도
      for (int i = 0; i < 3; i++) {
        print('APNS 토큰 시도 ${i+1} 시작...');
        try {
          final apnsToken = await messaging.getAPNSToken();
          print('APNS 토큰 시도 ${i+1}: $apnsToken');
          if (apnsToken != null) {
            print('APNS 토큰 획득 성공!');
            try {
              final token = await messaging.getToken();
              print('FCM 토큰 획득 성공: $token');
              break;
            } catch (e) {
              print('FCM 토큰 가져오기 실패: $e');
              print('에러 타입: ${e.runtimeType}');
            }
          } else {
            print('APNS 토큰이 null임');
          }
        } catch (e) {
          print('APNS 토큰 가져오기 중 에러: $e');
          print('에러 타입: ${e.runtimeType}');
        }
        print('${i+1}번째 시도 완료, 2초 대기...');
        await Future.delayed(Duration(seconds: 2));
      }
    }
    
    runApp(const MyApp());
    print('앱 실행 완료');
  } catch (e) {
    print('초기화 중 에러 발생: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
