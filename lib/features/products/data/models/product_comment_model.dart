import '../../domain/entities/product_comment_entity.dart';

class ProductCommentModel {
  final String id;
  final String commentId; // parent comment thread id
  final String? text;
  final String? senderId;
  final String? senderName;
  final String? senderRole; // 'client' | 'market'
  final DateTime createdAt;
  final double rating;

  const ProductCommentModel({
    required this.id,
    required this.commentId,
    this.text,
    this.senderId,
    this.senderName,
    this.senderRole,
    required this.createdAt,
    this.rating = 0.0,
  });

  factory ProductCommentModel.fromJson(Map<String, dynamic> json) {
    // Sender info
    String senderId = '';
    String senderName = 'Foydalanuvchi';
    String senderRole = 'client';

    final clientData = json['client'] as Map<String, dynamic>?;
    final marketData = json['market'] as Map<String, dynamic>?;

    if (clientData != null) {
      senderId = clientData['id'] as String? ?? '';
      senderName = (clientData['fullName'] ?? clientData['username'] ?? 'Foydalanuvchi') as String;
      senderRole = 'client';
    } else if (marketData != null) {
      senderId = marketData['id'] as String? ?? '';
      senderName = (marketData['name'] ?? 'Sotuvchi') as String;
      senderRole = 'market';
    }

    return ProductCommentModel(
      id: json['id'] as String? ?? '',
      commentId: json['commentId'] as String? ?? '',
      text: json['text'] as String?,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson({required String productCommentId}) => {
        'commentId': productCommentId,
        'text': text ?? '',
      };

  ProductCommentEntity toEntity(String productId) => ProductCommentEntity(
        id: id,
        productId: productId,
        userId: senderId ?? '',
        userName: senderName ?? 'Foydalanuvchi',
        authorType: senderRole == 'market'
            ? ProductCommentAuthor.seller
            : ProductCommentAuthor.user,
        content: text ?? '',
        createdAt: createdAt,
        rating: rating,
      );
}
