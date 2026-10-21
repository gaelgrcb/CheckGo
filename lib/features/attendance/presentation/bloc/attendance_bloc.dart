import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/register_attendance.dart';
import '../../domain/usecases/sync_offline_records.dart';
import '../../domain/usecases/get_attendance_summary.dart';
import '../../../../core/services/time_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../branches/domain/entities/branch.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final RegisterAttendanceUseCase registerUseCase;
  final SyncOfflineRecordsUseCase syncUseCase;
  final GetAttendanceSummaryUseCase summaryUseCase;
  final TimeService timeService;
  final LocationService locationService;

  AttendanceBloc({
    required this.registerUseCase,
    required this.syncUseCase,
    required this.summaryUseCase,
    required this.timeService,
    required this.locationService,
  }) : super(AttendanceStateData()) {
    
    on<LoadAttendanceDataEvent>((event, emit) async {
      await _loadSummary(emit);
    });

    on<RegisterCheckInEvent>((event, emit) async {
      await _handleRegistration(event.userId, event.branchId, AttendanceType.entry, emit);
    });

    on<RegisterCheckOutEvent>((event, emit) async {
      await _handleRegistration(event.userId, event.branchId, AttendanceType.exit, emit);
    });

    on<SyncRecordsEvent>((event, emit) async {
      final current = _currentState();
      emit(current.copyWith(isSyncing: true, clearMessages: true));
      try {
        await syncUseCase.call();
        final summary = await summaryUseCase.call();
        emit(current.copyWith(
          isSyncing: false,
          recentRecords: summary.recentRecords,
          pendingCount: summary.pendingCount,
          successMessage: 'Registros sincronizados con éxito',
        ));
      } catch (e) {
        emit(current.copyWith(
          isSyncing: false,
          errorMessage: 'Error al sincronizar: $e',
        ));
      }
    });
  }

  AttendanceStateData _currentState() {
    if (state is AttendanceStateData) {
      return state as AttendanceStateData;
    }
    return AttendanceStateData();
  }

  Future<void> _loadSummary(Emitter<AttendanceState> emit) async {
    final current = _currentState();
    try {
      final summary = await summaryUseCase.call();
      emit(current.copyWith(
        recentRecords: summary.recentRecords,
        pendingCount: summary.pendingCount,
        lastRecord: summary.recentRecords.isNotEmpty ? summary.recentRecords.first : null,
      ));
    } catch (_) {
      // Ignorar fallo en carga inicial silenciosa
    }
  }

  Future<void> _handleRegistration(
    String userId,
    String branchId,
    AttendanceType type,
    Emitter<AttendanceState> emit,
  ) async {
    final current = _currentState();
    emit(current.copyWith(isLoading: true, clearMessages: true));
    try {
      // 1. Validar ubicación
      final currentPos = await locationService.getCurrentLocation();
      final mockBranch = Branch(
        id: branchId,
        name: 'Sucursal Mazatlan',
        latitude: 19.4326,
        longitude: -99.1332,
        toleranceRadiusMeters: 50000, // Radio permisivo para pruebas y emulador
      );

      final isWithin = locationService.isWithinBranch(currentPos, mockBranch);
      if (!isWithin) {
        emit(current.copyWith(
          isLoading: false,
          errorMessage: 'Estás fuera del radio de la sucursal permitida.',
        ));
        return;
      }

      // 2. Obtener hora oficial NTP
      final officialTime = await timeService.getOfficialTime();

      // 3. Crear registro
      final record = AttendanceRecord(
        id: const Uuid().v4(),
        userId: userId,
        branchId: branchId,
        timestamp: officialTime,
        type: type,
        syncStatus: SyncStatus.pending,
        latitude: currentPos.latitude,
        longitude: currentPos.longitude,
      );

      // 4. Guardar localmente y sincronizar si hay red
      await registerUseCase.call(record);

      // 5. Cargar resumen actualizado
      final summary = await summaryUseCase.call();
      final actionText = type == AttendanceType.entry ? 'Entrada registrada' : 'Salida registrada';

      emit(current.copyWith(
        isLoading: false,
        recentRecords: summary.recentRecords,
        pendingCount: summary.pendingCount,
        lastRecord: record,
        successMessage: '$actionText con éxito',
      ));
    } catch (e) {
      emit(current.copyWith(
        isLoading: false,
        errorMessage: 'Error al registrar: $e',
      ));
    }
  }
}
