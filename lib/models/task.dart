class Task {
  int? id;
  String title;
  int? categoryId;
  double? timeNeeded; // hours
  String? motivation;
  bool isForMe;
  String status; // idea_dump, focus, blocked, completed
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    this.categoryId,
    this.timeNeeded,
    this.motivation,
    this.isForMe = false,
    this.status = "idea_dump",
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'timeNeeded': timeNeeded,
      'motivation': motivation,
      'isForMe': isForMe ? 1 : 0,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      categoryId: map['categoryId'],
      timeNeeded: map['timeNeeded'] != null
          ? (map['timeNeeded'] as num).toDouble()
          : null,
      motivation: map['motivation'],
      isForMe: map['isForMe'] == 1,
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
    );
  }
}
