import 'package:isar/isar.dart';
import '../../domain/entities/attendance_record.dart';

part 'attendance_record_isar.g.dart';

@collection
class AttendanceRecordIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String userId;
  late String branchId;
  late DateTime timestamp;

  @enumerated
  late AttendanceType type;

  @enumerated
  late SyncStatus syncStatus;

  late double latitude;
  late double longitude;
  late String securityHash;

  AttendanceRecord toDomain() {
    return AttendanceRecord(
      id: id,
      userId: userId,
      branchId: branchId,
      timestamp: timestamp,
      type: type,
      syncStatus: syncStatus,
      latitude: latitude,
      longitude: longitude,
      securityHash: securityHash,
    );
  }

  static AttendanceRecordIsar fromDomain(AttendanceRecord record) {
    return AttendanceRecordIsar()
      ..id = record.id
      ..userId = record.userId
      ..branchId = record.branchId
      ..timestamp = record.timestamp
      ..type = record.type
      ..syncStatus = record.syncStatus
      ..latitude = record.latitude
      ..longitude = record.longitude
      ..securityHash = record.securityHash;
  }
}
