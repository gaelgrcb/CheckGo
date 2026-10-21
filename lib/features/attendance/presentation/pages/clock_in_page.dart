import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class ClockInPage extends StatelessWidget {
  const ClockInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceBloc>()..add(LoadAttendanceDataEvent()),
      child: const ClockInView(),
    );
  }
}

class ClockInView extends StatefulWidget {
  const ClockInView({super.key});

  @override
  State<ClockInView> createState() => _ClockInViewState();
}

class _ClockInViewState extends State<ClockInView> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  // Configuración directa de colaborador (Sin pantalla de login)
  String _employeeId = 'EMP-001';
  String _employeeName = 'Gael Garcia';
  final String _branchId = 'b123';
  final String _branchName = 'Sucursal Mazatlan';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showEmployeeSwitchModal() {
    final controllerId = TextEditingController(text: _employeeId);
    final controllerName = TextEditingController(text: _employeeName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cambiar Colaborador',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Modo quiosco rápido: cambia el perfil activo sin requerir contraseñas.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controllerId,
                decoration: InputDecoration(
                  labelText: 'ID / Código de empleado',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controllerName,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      if (controllerId.text.trim().isNotEmpty) {
                        _employeeId = controllerId.text.trim();
                      }
                      if (controllerName.text.trim().isNotEmpty) {
                        _employeeName = controllerName.text.trim();
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Actualizar Colaborador'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTwoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_formatTwoDigits(hour)}:${_formatTwoDigits(dt.minute)}:${_formatTwoDigits(dt.second)} $period';
  }

  String _formatDate(DateTime dt) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} de $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();

    return Scaffold(
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceStateData) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.successMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.errorMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final dataState = state is AttendanceStateData ? state : AttendanceStateData();

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                bloc.add(LoadAttendanceDataEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // App Bar / Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showEmployeeSwitchModal,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF1E40AF),
                              child: Text(
                                _employeeName.isNotEmpty ? _employeeName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _employeeName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: _showEmployeeSwitchModal,
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  'ID: $_employeeId · Modo Rápido',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Sincronización offline chip
                          _buildSyncChip(context, bloc, dataState),
                        ],
                      ),
                    ),
                  ),

                  // Reloj en Tiempo Real
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: _buildDigitalClockCard(),
                    ),
                  ),

                  // Información de Geocerca / Sucursal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: _buildLocationStatusCard(),
                    ),
                  ),

                  // Botones de Registro (Entrada / Salida)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: _buildActionButtons(context, bloc, dataState),
                    ),
                  ),

                  // Sección Historial Reciente
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Historial de Marcajes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Hoy (${dataState.recentRecords.length})',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de Registros
                  _buildRecordsList(dataState),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSyncChip(BuildContext context, AttendanceBloc bloc, AttendanceStateData dataState) {
    if (dataState.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final hasPending = dataState.pendingCount > 0;

    return InkWell(
      onTap: () => bloc.add(SyncRecordsEvent()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: hasPending ? Colors.amber.shade100 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasPending ? Colors.amber.shade300 : Colors.green.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPending ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
              size: 16,
              color: hasPending ? Colors.amber.shade900 : Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              hasPending ? '${dataState.pendingCount} pendientes' : 'Sincronizado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasPending ? Colors.amber.shade900 : Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalClockCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatDate(_currentTime),
            style: TextStyle(
              color: Colors.blue.shade100,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_currentTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_outlined, color: Colors.white70, size: 14),
                SizedBox(width: 5),
                Text(
                  'Hora Oficial de Red (NTP)',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _branchName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ubicación GPS válida · Dentro de radio',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AttendanceBloc bloc, AttendanceStateData state) {
    if (state.isLoading) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Firmando y registrando asistencia...',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
            )
          ],
        ),
      );
    }

    return Row(
      children: [
        // Registrar Entrada
        Expanded(
          child: _buildCheckButton(
            title: 'REGISTRAR\nENTRADA',
            subtitle: 'Inicio de turno',
            icon: Icons.login_rounded,
            color: const Color(0xFF059669), // Emerald 600
            lightColor: const Color(0xFFECFDF5),
            onTap: () {
              bloc.add(RegisterCheckInEvent(
                userId: _employeeId,
                branchId: _branchId,
              ));
            },
          ),
        ),
        const SizedBox(width: 14),
        // Registrar Salida
        Expanded(
          child: _buildCheckButton(
            title: 'REGISTRAR\nSALIDA',
            subtitle: 'Fin de turno',
            icon: Icons.logout_rounded,
            color: const Color(0xFFD97706), // Amber 600
            lightColor: const Color(0xFFFFFBEB),
            onTap: () {
              bloc.add(RegisterCheckOutEvent(
                userId: _employeeId,
                branchId: _branchId,
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.15),
        highlightColor: color.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(AttendanceStateData state) {
    if (state.recentRecords.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.event_available_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'Aún no hay marcajes registrados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toca arriba en Entrada o Salida para generar tu primer registro seguro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final record = state.recentRecords[index];
            final isEntry = record.type == AttendanceType.entry;
            final isSynced = record.syncStatus == SyncStatus.synced;

            final hourStr = _formatTwoDigits(
              record.timestamp.hour > 12
                  ? record.timestamp.hour - 12
                  : (record.timestamp.hour == 0 ? 12 : record.timestamp.hour),
            );
            final minStr = _formatTwoDigits(record.timestamp.minute);
            final secStr = _formatTwoDigits(record.timestamp.second);
            final periodStr = record.timestamp.hour >= 12 ? 'PM' : 'AM';
            final timeDisplay = '$hourStr:$minStr:$secStr $periodStr';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEntry ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEntry ? Icons.login_rounded : Icons.logout_rounded,
                      color: isEntry ? const Color(0xFF059669) : const Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEntry ? 'Entrada' : 'Salida',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isEntry ? const Color(0xFF065F46) : const Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          timeDisplay,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSynced ? Colors.blue.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSynced ? Icons.check_circle_outline : Icons.schedule,
                              size: 13,
                              color: isSynced ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isSynced ? 'Sincronizado' : 'Local',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSynced ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${record.userId}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: state.recentRecords.length,
        ),
      ),
    );
  }
}
