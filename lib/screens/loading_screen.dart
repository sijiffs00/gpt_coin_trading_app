import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor 속성 대신 Container로 감싸서 그라데이션 적용
      body: Container(
        // 여기에 그라데이션 배경 설정
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9E7FE),  
              Color(0xFFDAFCFC),  
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/running_gom.gif',
                width: 300,  
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
      ),
    );
  }
}