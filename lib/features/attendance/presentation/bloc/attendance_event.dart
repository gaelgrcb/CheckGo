abstract class AttendanceEvent {}

class RegisterCheckInEvent extends AttendanceEvent {
  final String userId;
  final String branchId;
  
  RegisterCheckInEvent({required this.userId, required this.branchId});
}

class RegisterCheckOutEvent extends AttendanceEvent {
  final String userId;
  final String branchId;

  RegisterCheckOutEvent({required this.userId, required this.branchId});
}

class SyncRecordsEvent extends AttendanceEvent {}
