import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white, // 네비게이션바 배경색을 하얀색으로 설정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '매매기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '그래프',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.purple[200],
        unselectedItemColor: Colors.grey,
        onTap: onTap,
      ),
    );
  }
}