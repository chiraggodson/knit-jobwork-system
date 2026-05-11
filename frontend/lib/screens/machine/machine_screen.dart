import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/machine_model.dart';
import '../../providers/machine_provider.dart';
import '../../services/api/machine_api.dart';

class MachineScreen extends ConsumerStatefulWidget {
  const MachineScreen({super.key});

  @override
  ConsumerState<MachineScreen> createState() =>
      _MachineScreenState();
}

class _MachineScreenState
    extends ConsumerState<MachineScreen> {

  Timer? refreshTimer;

  MachineModel? selectedMachine;

  bool showPanel = false;
  double panelWidth = 350;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(machineProvider.notifier)
          .loadMachines();
    });

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => ref
          .read(machineProvider.notifier)
          .loadMachines(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  /*
  =================================
  FIND MACHINE
  =================================
  */

  MachineModel? getMachine(
    int machineNo,
    List<MachineModel> machines,
  ) {
    try {
      return machines.firstWhere(
        (m) =>
            int.tryParse(m.machineNo) ==
            machineNo,
      );
    } catch (_) {
      return null;
    }
  }

  /*
  =================================
  STATUS COLOR
  =================================
  */

  Color statusColor(String status) {
    switch (status) {
      case "RUNNING":
        return Colors.greenAccent;

      case "STOPPED":
        return Colors.redAccent;

      case "CLEANING":
        return Colors.orangeAccent;

      case "YARN_REQUIRED":
        return Colors.yellowAccent;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final machineState =
        ref.watch(machineProvider);

    final machines =
        machineState.machines;

    if (machineState.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        Container(
          color: const Color(0xFF121212),
          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {

                int columns =
                    constraints.maxWidth > 1400
                        ? 4
                        : constraints.maxWidth > 900
                            ? 2
                            : 1;

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Factory Command Center",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /*
                    =================================
                    METRICS
                    =================================
                    */

                    Wrap(
                      spacing: 20,
                      runSpacing: 20,

                      children: [
                        _metricCardNew(
                          "Machines Running",
                          "${machineState.running}",
                          Icons
                              .precision_manufacturing,
                          Colors.greenAccent,
                          columns,
                          constraints,
                        ),

                        _metricCardNew(
                          "Machines Stopped",
                          "${machineState.stopped}",
                          Icons
                              .warning_amber_rounded,
                          Colors.orangeAccent,
                          columns,
                          constraints,
                        ),

                        _metricCardNew(
                          "Total Machines",
                          "${machines.length}",
                          Icons.factory,
                          const Color(
                            0xFF00BFA6,
                          ),
                          columns,
                          constraints,
                        ),

                        _metricCardNew(
                          "Yarn Alerts",
                          "${machineState.alerts}",
                          Icons.inventory,
                          Colors.redAccent,
                          columns,
                          constraints,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    _buildFloor(
                      "Ground Floor",
                      [
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12,
                      ],
                      constraints,
                      machines,
                    ),

                    const SizedBox(height: 30),

                    _buildFloor(
                      "Second Floor",
                      [
                        13,
                        14,
                        15,
                        16,
                        17,
                        18,
                        19,
                        20,
                        21,
                        26,
                        27,
                        28,
                        29,
                      ],
                      constraints,
                      machines,
                    ),

                    const SizedBox(height: 30),

                    _buildFloor(
                      "Third Floor",
                      [
                        22,
                        23,
                        24,
                        25,
                        30,
                        31,
                      ],
                      constraints,
                      machines,
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        /*
        =================================
        RIGHT PANEL
        =================================
        */

        if (showPanel)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,

            child: Row(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate:
                      (details) {

                    setState(() {
                      panelWidth -=
                          details.delta.dx;

                      panelWidth =
                          panelWidth.clamp(
                        250,
                        600,
                      );
                    });
                  },

                  child: Container(
                    width: 6,
                    color:
                        Colors.grey.shade800,
                  ),
                ),

                Container(
                  width: panelWidth,
                  color:
                      const Color(0xFF1A1A1A),
                  padding:
                      const EdgeInsets.all(20),

                  child:
                      selectedMachine == null
                          ? const Text(
                              "No Machine",
                            )
                          : _buildDetails(
                              selectedMachine!,
                            ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /*
  =================================
  BUILD FLOOR
  =================================
  */

  Widget _buildFloor(
    String title,
    List<int> machinesList,
    BoxConstraints constraints,
    List<MachineModel> machines,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: machinesList.length,

          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                constraints.maxWidth > 1500
                    ? 8
                    : constraints.maxWidth > 1200
                        ? 6
                        : 4,

            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),

          itemBuilder: (context, index) {

            int machineNumber =
                machinesList[index];

            final m = getMachine(
              machineNumber,
              machines,
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMachine = m;
                  showPanel = true;
                });
              },

              child: _machineCard(
                machineNumber,
                m,
              ),
            );
          },
        ),
      ],
    );
  }

  /*
  =================================
  MACHINE CARD
  =================================
  */

  Widget _machineCard(
    int machineNo,
    MachineModel? m,
  ) {

    final status =
        m?.status ?? "STOPPED";

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.grey.shade800,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            "M-$machineNo",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "RPM: ${m?.rpm ?? 0}",
            style:
                const TextStyle(fontSize: 11),
          ),

          Text(
            "Job: ${m?.jobNo ?? "-"}",
            style:
                const TextStyle(fontSize: 11),
          ),

          const Spacer(),

          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: statusColor(status),
              ),

              const SizedBox(width: 6),

              Text(
                status,
                style: TextStyle(
                  color: statusColor(status),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  =================================
  METRIC CARD
  =================================
  */

  Widget _metricCardNew(
    String title,
    String value,
    IconData icon,
    Color color,
    int columns,
    BoxConstraints constraints,
  ) {
    return Container(
      width: constraints.maxWidth /
              columns -
          20,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade800,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 36,
            color: color,
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  =================================
  DETAILS PANEL
  =================================
  */

  Widget _buildDetails(
    MachineModel m,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          "Machine ${m.machineNo}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text("Status: ${m.status}"),
        Text("RPM: ${m.rpm}"),
        Text("Counter: ${m.counter}"),
        Text(
          "Roll Size: ${m.rollSize} kg",
        ),
        Text("Job: ${m.jobNo}"),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () =>
              _showPerformanceDialog(m),

          child: const Text(
            "Update Performance",
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                statusColor(m.status),
          ),

          onPressed: () =>
              _changeStatus(m),

          child: const Text(
            "Change Status",
          ),
        ),
      ],
    );
  }

  /*
  =================================
  PERFORMANCE DIALOG
  =================================
  */

  Future<void>
      _showPerformanceDialog(
    MachineModel machine,
  ) async {

    final rpmController =
        TextEditingController(
      text: machine.rpm.toString(),
    );

    final counterController =
        TextEditingController(
      text: machine.counter.toString(),
    );

    final rollSizeController =
        TextEditingController(
      text:
          machine.rollSize.toString(),
    );

    await showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            title: const Text(
              "Update Machine",
            ),

            content: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                TextField(
                  controller:
                      rpmController,
                ),

                TextField(
                  controller:
                      counterController,
                ),

                TextField(
                  controller:
                      rollSizeController,
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                    ),

                child: const Text(
                  "Cancel",
                ),
              ),

              ElevatedButton(
                onPressed: () async {

                  await MachineApi
                      .updateMachinePerformance(
                    machineId:
                        machine.id,

                    rpm:
                        int.tryParse(
                          rpmController
                              .text,
                        ) ??
                        0,

                    counter:
                        int.tryParse(
                          counterController
                              .text,
                        ) ??
                        0,

                    rollSize:
                        double.tryParse(
                          rollSizeController
                              .text,
                        ) ??
                        0,
                  );

                  Navigator.pop(
                    context,
                  );

                  ref
                      .read(
                        machineProvider
                            .notifier,
                      )
                      .loadMachines();
                },

                child: const Text(
                  "Save",
                ),
              ),
            ],
          ),
    );
  }

  /*
  =================================
  CHANGE STATUS
  =================================
  */

  Future<void> _changeStatus(
    MachineModel machine,
  ) async {

    final statuses = [
      "RUNNING",
      "STOPPED",
      "CLEANING",
      "YARN_REQUIRED",
    ];

    await showModalBottomSheet(
      context: context,

      builder: (_) {
        return Container(
          padding:
              const EdgeInsets.all(16),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children:
                statuses.map((status) {

              return ListTile(
                leading: Icon(
                  Icons.circle,
                  color:
                      statusColor(status),
                ),

                title: Text(status),

                onTap: () async {

                  Navigator.pop(
                    context,
                  );

                  await MachineApi
                      .updateMachineStatus(
                    machine.id,
                    status,
                  );

                  ref
                      .read(
                        machineProvider
                            .notifier,
                      )
                      .loadMachines();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}