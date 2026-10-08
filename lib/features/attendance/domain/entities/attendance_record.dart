enum AttendanceType { entry, exit }
enum SyncStatus { pending, synced, failed }

class AttendanceRecord {
  final String id;
  final String userId;
  final String branchId;
  final DateTime timestamp;
  final AttendanceType type;
  final SyncStatus syncStatus;
  final double latitude;
  final double longitude;
  final String securityHash;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.timestamp,
    required this.type,
    required this.syncStatus,
    required this.latitude,
    required this.longitude,
    this.securityHash = '',
  });

  AttendanceRecord copyWith({
    String? id,
    String? userId,
    String? branchId,
    DateTime? timestamp,
    AttendanceType? type,
    SyncStatus? syncStatus,
    double? latitude,
    double? longitude,
    String? securityHash,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      branchId: branchId ?? this.branchId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      syncStatus: syncStatus ?? this.syncStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      securityHash: securityHash ?? this.securityHash,
    );
  }
}
