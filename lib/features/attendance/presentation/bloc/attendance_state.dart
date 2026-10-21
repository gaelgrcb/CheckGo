import '../../domain/entities/attendance_record.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceStateData extends AttendanceState {
  final bool isLoading;
  final bool isSyncing;
  final List<AttendanceRecord> recentRecords;
  final int pendingCount;
  final String? successMessage;
  final String? errorMessage;
  final AttendanceRecord? lastRecord;

  AttendanceStateData({
    this.isLoading = false,
    this.isSyncing = false,
    this.recentRecords = const [],
    this.pendingCount = 0,
    this.successMessage,
    this.errorMessage,
    this.lastRecord,
  });

  AttendanceStateData copyWith({
    bool? isLoading,
    bool? isSyncing,
    List<AttendanceRecord>? recentRecords,
    int? pendingCount,
    String? successMessage,
    String? errorMessage,
    AttendanceRecord? lastRecord,
    bool clearMessages = false,
  }) {
    return AttendanceStateData(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      recentRecords: recentRecords ?? this.recentRecords,
      pendingCount: pendingCount ?? this.pendingCount,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      lastRecord: lastRecord ?? this.lastRecord,
    );
  }
}
