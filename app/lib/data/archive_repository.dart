import '../models/archive_entry.dart';
import 'sample_archive_entries.dart';

class ArchiveRepository {
  ArchiveRepository();

  bool get isRemoteEnabled => false;

  Future<List<ArchiveEntry>> fetchEntries() async {
    // Backend integration pending - return sample data
    return sampleArchiveEntries;
  }
}
