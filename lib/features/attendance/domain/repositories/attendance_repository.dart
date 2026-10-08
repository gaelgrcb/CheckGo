import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<void> registerAttendance(AttendanceRecord record);
  Future<void> syncPendingRecords();
}
