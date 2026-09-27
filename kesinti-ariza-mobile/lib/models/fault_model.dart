class FaultModel {
  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final int userId;
  final DateTime createdAt;

  FaultModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  // Backend'den gelen JSON verisini Flutter'ın anlayacağı Dart nesnesine çeviren fabrika
  factory FaultModel.fromJson(Map<String, dynamic> json) {
    return FaultModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(), // Tam sayı gelirse double'a çevirmeyi garantiye alır
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}