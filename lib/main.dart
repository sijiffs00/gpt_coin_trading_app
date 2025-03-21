import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gpt_coin_trading/my_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/loading_screen.dart';

// 서버 주소 설정
// const String serverUrl = 'http://172.30.1.6:8000';  // 맥북 로컬 
const String serverUrl = 'http://15.164.48.123:8000';  // EC2

// 백그라운드 메시지를 처리하는 함수야
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("백그라운드 메시지 도착!: ${message.messageId}");
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter Binding 초기화 완료');
    
    // 앱 실행 - 나머지 초기화는 FutureBuilder에서 처리
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
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      //   useMaterial3: true,
      //   fontFamily: '읏맨체',  // 앱 전체 기본 폰트
      // ),
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

// 앱 초기화 함수
Future<void> _initializeApp() async {
  try {
    // 날짜 포맷 초기화
    await initializeDateFormatting('ko_KR', null);
    print('날짜 포맷 초기화 완료');
    
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 완료');
    
    // FCM 백그라운드 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('FCM 백그라운드 핸들러 설정 완료');
    
    // FCM 권한 요청
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('FCM 권한 요청 완료');

    // iOS에서만 실행되는 코드
    if (Platform.isIOS) {
      await _setupIOSNotifications(messaging);
    } else {
      // Android인 경우 토큰 바로 가져오기
      await _sendFCMTokenToServer(messaging);
    }
  } catch (e) {
    print('앱 초기화 중 에러 발생: $e');
  }
}

// iOS 알림 설정 함수
Future<void> _setupIOSNotifications(FirebaseMessaging messaging) async {
  print('iOS FCM 설정 시작');
  for (int i = 0; i < 3; i++) {
    try {
      final apnsToken = await messaging.getAPNSToken();
      print('APNS 토큰: $apnsToken');
      
      if (apnsToken != null) {
        await _sendFCMTokenToServer(messaging);
        break;
      }
    } catch (e) {
      print('iOS 토큰 처리 중 에러: $e');
    }
    await Future.delayed(const Duration(seconds: 2));
  }
}

// FCM 토큰을 서버에 전송하는 함수
Future<void> _sendFCMTokenToServer(FirebaseMessaging messaging) async {
  try {
    final token = await messaging.getToken();
    print('FCM 토큰: $token');
    
    if (token != null) {
      final response = await http.post(
        Uri.parse('$serverUrl/api/fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      print('FCM 토큰 서버 전송 결과: ${response.statusCode}');
    }
  } catch (e) {
    print('FCM 토큰 서버 전송 중 에러: $e');
  }
}

enum DataStatus { success, empty, error }

