import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationModel>>> getNotifications({int page = 1});
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markRead(String id);
  Future<Result<void>> markAllRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient client;

  NotificationRepositoryImpl({required this.client});

  @override
  Future<Result<List<NotificationModel>>> getNotifications({int page = 1}) async {
    final response = await client.get<Map<String, dynamic>>('notification/me', queryParams: {'page': page, 'limit': 20});
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok((data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    final response = await client.get<Map<String, dynamic>>('notification/unread-count');
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data']['count'] as int),
    );
  }

  @override
  Future<Result<void>> markRead(String id) async {
    final response = await client.patch<Map<String, dynamic>>('notification/$id/read', data: {});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<void>> markAllRead() async {
    final response = await client.patch<Map<String, dynamic>>('notification/read-all', data: {});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }
}
