import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class AttendanceSummaryData {
  final List<AttendanceRecord> recentRecords;
  final int pendingCount;

  AttendanceSummaryData({
    required this.recentRecords,
    required this.pendingCount,
  });
}

class GetAttendanceSummaryUseCase {
  final AttendanceRepository repository;

  GetAttendanceSummaryUseCase(this.repository);

  Future<AttendanceSummaryData> call() async {
    final recent = await repository.getRecentRecords(limit: 10);
    final pendingCount = await repository.getPendingCount();
    return AttendanceSummaryData(recentRecords: recent, pendingCount: pendingCount);
  }
}
