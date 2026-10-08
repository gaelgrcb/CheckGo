import '../../domain/entities/attendance_record.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> sendRecord(AttendanceRecord record);
}
