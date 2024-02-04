class IncomeCategory {
  int id;
  String name;
  String? icon;

  IncomeCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  Map<String, Object> toMap() {
    return {'id': id, 'nama': name};
  }

  static IncomeCategory fromMap(Map<String, dynamic> map) {
    return IncomeCategory(id: map['id'], name: map['nama'], icon: map['icon']);
  }

  IncomeCategory copyWith({int? id, String? name, String? icon}) {
    return IncomeCategory(
        id: id ?? this.id, name: name ?? this.name, icon: icon ?? this.icon);
  }
}
