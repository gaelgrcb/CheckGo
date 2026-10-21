import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import '../features/attendance/data/datasources/attendance_local_data_source.dart';
import '../features/attendance/data/datasources/attendance_local_data_source_isar.dart';
import '../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../features/attendance/domain/repositories/attendance_repository.dart';
import '../features/attendance/domain/usecases/register_attendance.dart';
import '../features/attendance/domain/usecases/sync_offline_records.dart';
import '../features/attendance/domain/usecases/get_attendance_summary.dart';
import '../features/attendance/presentation/bloc/attendance_bloc.dart';
import 'database/isar_helper.dart';
import 'network/network_info.dart';
import 'services/location_service.dart';
import 'services/time_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Isar DB
  final isar = await IsarHelper.init();
  sl.registerLazySingleton<Isar>(() => isar);

  // Core Services
  sl.registerLazySingleton<TimeService>(() => TimeServiceImpl());
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Data Sources
  sl.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceIsar(sl()),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => RegisterAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => SyncOfflineRecordsUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceSummaryUseCase(sl()));

  // BLoC
  sl.registerFactory(() => AttendanceBloc(
        registerUseCase: sl(),
        syncUseCase: sl(),
        summaryUseCase: sl(),
        timeService: sl(),
        locationService: sl(),
      ));
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // Mock para simplificar
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  @override
  Future<void> sendRecord(record) async {
    // Aquí iría el HTTP POST a la API usando Dio.
    await Future.delayed(const Duration(seconds: 1)); // Simula red
  }
}
