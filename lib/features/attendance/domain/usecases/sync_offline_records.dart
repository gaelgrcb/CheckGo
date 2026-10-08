import '../repositories/attendance_repository.dart';

class SyncOfflineRecordsUseCase {
  final AttendanceRepository repository;

  SyncOfflineRecordsUseCase(this.repository);

  Future<void> call() async {
    return await repository.syncPendingRecords();
  }
}
