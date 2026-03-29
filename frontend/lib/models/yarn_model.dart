class Yarn {
  final int id;
  final String yarnName;
  final double stock;

  Yarn({
    required this.id,
    required this.yarnName,
    required this.stock,
  });

  factory Yarn.fromJson(Map<String, dynamic> json) {
    return Yarn(
      id: json['id'],
      yarnName: json['yarn_name'] ?? '',
      stock: (json['stock'] ?? 0).toDouble(),
    );
  }
}