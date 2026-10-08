import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class RegisterAttendanceUseCase {
  final AttendanceRepository repository;

  RegisterAttendanceUseCase(this.repository);

  Future<void> call(AttendanceRecord record) async {
    return await repository.registerAttendance(record);
  }
}
