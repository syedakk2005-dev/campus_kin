class MatchModel {
  final String id;
  final String lostItemId;
  final String foundItemId;
  final double confidenceScore;
  final DateTime matchedDate;
  final bool userViewed;

  MatchModel({
    required this.id,
    required this.lostItemId,
    required this.foundItemId,
    required this.confidenceScore,
    required this.matchedDate,
    this.userViewed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lostItemId': lostItemId,
    'foundItemId': foundItemId,
    'confidenceScore': confidenceScore,
    'matchedDate': matchedDate.toIso8601String(),
    'userViewed': userViewed,
  };

  static MatchModel fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id'],
    lostItemId: json['lostItemId'],
    foundItemId: json['foundItemId'],
    confidenceScore: json['confidenceScore'],
    matchedDate: DateTime.parse(json['matchedDate']),
    userViewed: json['userViewed'] ?? false,
  );
}