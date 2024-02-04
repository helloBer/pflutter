class Goal {
  int id;
  String name;
  double totalAmount;
  double progressAmount;

  Goal(
      {required this.id,
      required this.name,
      required this.totalAmount,
      required this.progressAmount});

  Map<String, Object> toMap() {
    return {
      'id': id,
      'nama': name,
      'totalJumlah': totalAmount,
      'progresTarget': progressAmount,
    };
  }

  static Goal fromMap(Map<String, dynamic> map) {
    return Goal(
        id: map['id'],
        name: map['nama'],
        totalAmount: map['totalJumlah'],
        progressAmount: map['progresTarget']);
  }

  Goal copyWith(
      {int? id, String? name, double? totalAmount, double? progressAmount}) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      progressAmount: progressAmount ?? this.progressAmount,
    );
  }
}
