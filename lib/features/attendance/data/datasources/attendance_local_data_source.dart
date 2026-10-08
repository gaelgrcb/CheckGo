import '../../domain/entities/attendance_record.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveRecord(AttendanceRecord record);
  Future<void> updateRecord(AttendanceRecord record);
  Future<List<AttendanceRecord>> getPendingRecords();
}
