class Trade {
  final int? id;
  final String? timestamp;
  final String? img;
  final double? price;
  final String? decision;
  final int? percentage;
  final String? reason;
  final String? original_reason;

  Trade({
    this.id,
    this.timestamp,
    this.img,
    this.price,
    this.decision,
    this.percentage,
    this.reason,
    this.original_reason,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as int?,
      timestamp: json['timestamp'] as String?,
      img: json['img'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      decision: json['decision'] as String?,
      percentage: json['percentage'] as int?,
      reason: json['reason'] as String?,
      original_reason: json['original_reason'] as String?,
    );
  }
} 