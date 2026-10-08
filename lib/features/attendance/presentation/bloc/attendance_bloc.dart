import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/register_attendance.dart';
import '../../domain/usecases/sync_offline_records.dart';
import '../../../../core/services/time_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../branches/domain/entities/branch.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final RegisterAttendanceUseCase registerUseCase;
  final SyncOfflineRecordsUseCase syncUseCase;
  final TimeService timeService;
  final LocationService locationService;

  AttendanceBloc({
    required this.registerUseCase,
    required this.syncUseCase,
    required this.timeService,
    required this.locationService,
  }) : super(AttendanceInitial()) {
    
    on<RegisterCheckInEvent>((event, emit) async {
      await _handleRegistration(event.userId, event.branchId, AttendanceType.entry, emit);
    });

    on<RegisterCheckOutEvent>((event, emit) async {
      await _handleRegistration(event.userId, event.branchId, AttendanceType.exit, emit);
    });

    on<SyncRecordsEvent>((event, emit) async {
      emit(AttendanceLoading());
      try {
        await syncUseCase.call();
        emit(AttendanceSuccess('Registros sincronizados correctamente'));
      } catch (e) {
        emit(AttendanceFailure('Error al sincronizar: $e'));
      }
    });
  }

  Future<void> _handleRegistration(String userId, String branchId, AttendanceType type, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      // 1. Validar ubicación
      final currentPos = await locationService.getCurrentLocation();
      // TODO: Obtener sucursal real desde repositorio de sucursales. Esto es un Mock.
      final mockBranch = Branch(
        id: branchId, 
        name: 'Sucursal Matriz', 
        latitude: 19.4326, 
        longitude: -99.1332, 
        toleranceRadiusMeters: 50000 // Radio alto para poder probar
      );
      
      final isWithin = locationService.isWithinBranch(currentPos, mockBranch);
      if (!isWithin) {
        emit(AttendanceFailure('Estás fuera del radio de la sucursal permitida.'));
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

      // 4. Guardar localmente y tratar de sincronizar
      await registerUseCase.call(record);
      emit(AttendanceSuccess(type == AttendanceType.entry ? 'Entrada registrada' : 'Salida registrada'));
    } catch (e) {
      emit(AttendanceFailure('Error: $e'));
    }
  }
}
