import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<void> registerAttendance(AttendanceRecord record);
  Future<void> syncPendingRecords();
  Future<List<AttendanceRecord>> getRecentRecords({int limit = 10});
  Future<int> getPendingCount();
}
