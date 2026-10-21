import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<void> registerAttendance(AttendanceRecord record) async {
    final signedRecord = _signRecord(record);
    
    await localDataSource.saveRecord(signedRecord);

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendRecord(signedRecord);
        final syncedRecord = signedRecord.copyWith(syncStatus: SyncStatus.synced);
        await localDataSource.updateRecord(syncedRecord);
      } catch (e) {
        // Guardado localmente, se sincronizará después
      }
    }
  }

  @override
  Future<void> syncPendingRecords() async {
    if (!await networkInfo.isConnected) return;

    final pendingRecords = await localDataSource.getPendingRecords();
    for (var record in pendingRecords) {
      try {
        await remoteDataSource.sendRecord(record);
        await localDataSource.updateRecord(record.copyWith(syncStatus: SyncStatus.synced));
      } catch (e) {
        // Falló sincronización de este registro, intentar luego
      }
    }
  }

  @override
  Future<List<AttendanceRecord>> getRecentRecords({int limit = 10}) async {
    return await localDataSource.getRecentRecords(limit: limit);
  }

  @override
  Future<int> getPendingCount() async {
    return await localDataSource.getPendingCount();
  }

  AttendanceRecord _signRecord(AttendanceRecord record) {
    const secret = "atp_secure_salt_2023"; 
    var bytes = utf8.encode('${record.id}${record.timestamp.toIso8601String()}$secret');
    var hash = sha256.convert(bytes).toString();
    return record.copyWith(securityHash: hash);
  }
}
