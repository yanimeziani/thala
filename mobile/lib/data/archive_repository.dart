import 'dart:developer' as developer;
import '../models/archive_entry.dart';
import '../services/api_client.dart';

class ArchiveRepository {
  ArchiveRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<List<ArchiveEntry>> fetchEntries() async {
    if (!isRemoteEnabled) {
      developer.log('Archive: No auth token, returning empty list', name: 'ArchiveRepository');
      return [];
    }

    try {
      final response = await ApiClient.getList(
        '/archive',
        headers: ApiClient.authHeaders(accessToken!),
      );

      return response
          .map((json) => ArchiveEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to fetch archive: $e', name: 'ArchiveRepository', level: 1000);
      return [];
    }
  }
}
