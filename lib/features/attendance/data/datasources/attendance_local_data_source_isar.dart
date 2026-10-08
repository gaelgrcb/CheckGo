import 'package:isar/isar.dart';
import '../../domain/entities/attendance_record.dart';
import '../datasources/attendance_local_data_source.dart';
import '../models/attendance_record_isar.dart';

class AttendanceLocalDataSourceIsar implements AttendanceLocalDataSource {
  final Isar isar;

  AttendanceLocalDataSourceIsar(this.isar);

  @override
  Future<void> saveRecord(AttendanceRecord record) async {
    final isarRecord = AttendanceRecordIsar.fromDomain(record);
    await isar.writeTxn(() async {
      await isar.attendanceRecordIsars.put(isarRecord);
    });
  }

  @override
  Future<void> updateRecord(AttendanceRecord record) async {
    final isarRecord = AttendanceRecordIsar.fromDomain(record);
    await isar.writeTxn(() async {
      final existing = await isar.attendanceRecordIsars.where().idEqualTo(record.id).findFirst();
      if (existing != null) {
        isarRecord.isarId = existing.isarId;
        await isar.attendanceRecordIsars.put(isarRecord);
      }
    });
  }

  @override
  Future<List<AttendanceRecord>> getPendingRecords() async {
    final pendingIsarRecords = await isar.attendanceRecordIsars
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    return pendingIsarRecords.map((r) => r.toDomain()).toList();
  }
}
