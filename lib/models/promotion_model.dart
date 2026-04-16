
class PromotionModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? targetItemId; // Redirect to specific food item
  final bool isActive;
  final int priority; // Order in carousel

  PromotionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.targetItemId,
    this.isActive = true,
    this.priority = 0,
  });

  factory PromotionModel.fromMap(Map<String, dynamic> data, String docId) {
    return PromotionModel(
      id: docId,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      targetItemId: data['targetItemId'],
      isActive: data['isActive'] ?? true,
      priority: data['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'targetItemId': targetItemId,
      'isActive': isActive,
      'priority': priority,
    };
  }
}
