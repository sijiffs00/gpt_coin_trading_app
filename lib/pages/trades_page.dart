import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trade.dart';
import '../widgets/trade_card.dart';
import '../pages/trade_detail_page.dart';
import 'package:intl/intl.dart';
import '../main.dart';  // serverUrl 사용을 위한 import


class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}