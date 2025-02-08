class Trade {
  final String decision;
  final int id;
  final String img;
  final int percentage;
  final double price;
  final String reason;
  final String timestamp;

  Trade({
    required this.decision,
    required this.id,
    required this.img,
    required this.percentage,
    required this.price,
    required this.reason,
    required this.timestamp,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      decision: json['decision'],
      id: json['id'],
      img: json['img'],
      percentage: json['percentage'],
      price: json['price'],
      reason: json['reason'],
      timestamp: json['timestamp'],
    );
  }
} 