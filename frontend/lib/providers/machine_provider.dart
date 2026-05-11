import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/machine_model.dart';
import '../services/api/machine_api.dart';

/*
=================================
MACHINE STATE
=================================
*/

class MachineState {
  final bool loading;

  final List<MachineModel> machines;

  final int running;
  final int stopped;
  final int alerts;

  const MachineState({
    this.loading = true,
    this.machines = const [],
    this.running = 0,
    this.stopped = 0,
    this.alerts = 0,
  });

  MachineState copyWith({
    bool? loading,
    List<MachineModel>? machines,
    int? running,
    int? stopped,
    int? alerts,
  }) {
    return MachineState(
      loading: loading ?? this.loading,
      machines: machines ?? this.machines,
      running: running ?? this.running,
      stopped: stopped ?? this.stopped,
      alerts: alerts ?? this.alerts,
    );
  }
}

/*
=================================
MACHINE NOTIFIER
=================================
*/

class MachineNotifier
    extends Notifier<MachineState> {

  @override
  MachineState build() {
    return const MachineState();
  }

  /*
  =================================
  LOAD MACHINES
  =================================
  */

  Future<void> loadMachines() async {

    try {

      state = state.copyWith(
        loading: true,
      );

      final data =
          await MachineApi.getMachines();

      int run = 0;
      int stop = 0;
      int warn = 0;

      for (var m in data) {

        if (m.status == "RUNNING") {
          run++;
        }

        if (m.status == "STOPPED") {
          stop++;
        }

        if (m.status == "YARN_REQUIRED") {
          warn++;
        }
      }

      state = state.copyWith(
        loading: false,
        machines: data,
        running: run,
        stopped: stop,
        alerts: warn,
      );

    } catch (e) {

      state = state.copyWith(
        loading: false,
      );
    }
  }
}

/*
=================================
PROVIDER
=================================
*/

final machineProvider =
    NotifierProvider<
      MachineNotifier,
      MachineState
    >(
  MachineNotifier.new,
);