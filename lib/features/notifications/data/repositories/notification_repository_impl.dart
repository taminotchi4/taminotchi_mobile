import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationModel>>> getNotifications({int page = 1});
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markRead(String id);
  Future<Result<void>> markAllRead();
  Future<Result<void>> saveFcmToken(String token, String userRole);
  Future<Result<void>> clearFcmToken(String userRole);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient client;

  NotificationRepositoryImpl({required this.client});

  @override
  Future<Result<List<NotificationModel>>> getNotifications({int page = 1}) async {
    final response = await client.get<Map<String, dynamic>>(
      'notification/me',
      queryParams: {'page': page, 'limit': 20},
    );
    return response.fold(
      (error) => Result.error(error),
      (data) {
        final list = data['data'];
        if (list is! List) return Result.ok([]);
        return Result.ok(
          list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
        );
      },
    );
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    final response = await client.get<Map<String, dynamic>>('notification/unread-count');
    return response.fold(
      (error) => Result.error(error),
      (data) {
        final count = data['data']?['count'];
        return Result.ok((count as num?)?.toInt() ?? 0);
      },
    );
  }

  @override
  Future<Result<void>> markRead(String id) async {
    final response = await client.patch<Map<String, dynamic>>(
      'notification/$id/read',
      data: {},
    );
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<void>> markAllRead() async {
    final response = await client.patch<Map<String, dynamic>>(
      'notification/read-all',
      data: {},
    );
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  /// FCM tokenni backendga saqlash
  /// userRole: 'client' yoki 'market'
  @override
  Future<Result<void>> saveFcmToken(String token, String userRole) async {
    final endpoint = userRole == 'market'
        ? 'market/me/fcm-token'
        : 'client/me/fcm-token';
    final response = await client.patch<Map<String, dynamic>>(
      endpoint,
      data: {'token': token},
    );
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  /// Logout vaqtida FCM tokenni o'chirish
  @override
  Future<Result<void>> clearFcmToken(String userRole) async {
    return saveFcmToken('', userRole);
  }
}
