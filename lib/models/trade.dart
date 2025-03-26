class Trade {
  final int? id;
  final String? timestamp;
  final String? img;
  final double? price;
  final String? decision;
  final String? reason;
  final String? original_reason;
  final String? lookback;
  final double? amount;  // BTC 수량
  final double? total;   // 총 거래 금액

  Trade({
    this.id,
    this.timestamp,
    this.img,
    this.price,
    this.decision,
    this.reason,
    this.original_reason,
    this.lookback,
    this.amount,
    this.total,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as int?,
      timestamp: json['timestamp'] as String?,
      img: json['img'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      decision: json['decision'] as String?,
      reason: json['reason'] as String?,
      original_reason: json['original_reason'] as String?,
      lookback: json['lookback'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      total: json['total'] != null ? (json['total'] as num).toDouble() : null,
    );
  }

  // timestamp를 '오전/오후 시:분' 형식으로 변환하는 메서드
  String getFormattedTime() {
    if (timestamp == null) return '';
    
    final dateTime = DateTime.parse(timestamp!);
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // 오전/오후 구분
    final period = hour < 12 ? '오전' : '오후';
    
    // 12시간제로 변환
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    // 분이 한 자리 수일 경우 앞에 0 추가
    final minuteStr = minute < 10 ? '0$minute' : '$minute';
    
    return '$period $hour12:$minuteStr';
  }

  // price를 '1.234' 형식으로 변환하는 메서드
  String getFormattedPrice() {
    if (price == null) return '0.000';
    
    // 100,000,000으로 나누고 소수점 셋째 자리까지 표시
    final formattedValue = (price! / 100000000).toStringAsFixed(3);
    return formattedValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'img': img,
      'price': price,
      'decision': decision,
      'reason': reason,
      'original_reason': original_reason,
      'lookback': lookback,
      'amount': amount,
      'total': total,
    };
  }
} 