import '../../domain/entities/attendance_record.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveRecord(AttendanceRecord record);
  Future<void> updateRecord(AttendanceRecord record);
  Future<List<AttendanceRecord>> getPendingRecords();
  Future<List<AttendanceRecord>> getRecentRecords({int limit = 10});
  Future<int> getPendingCount();
}
