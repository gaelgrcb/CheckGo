import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class ClockInPage extends StatelessWidget {
  const ClockInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceBloc>(),
      child: const ClockInView(),
    );
  }
}

class ClockInView extends StatelessWidget {
  const ClockInView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATP Click-IN'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar Offline',
            onPressed: () => bloc.add(SyncRecordsEvent()),
          )
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AttendanceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, size: 120, color: Colors.blueAccent),
                const SizedBox(height: 40),
                if (state is AttendanceLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          bloc.add(RegisterCheckInEvent(userId: 'u123', branchId: 'b123'));
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Registrar Entrada'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () {
                          bloc.add(RegisterCheckOutEvent(userId: 'u123', branchId: 'b123'));
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Registrar Salida'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
