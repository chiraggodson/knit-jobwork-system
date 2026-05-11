import {
  createMachine,
  getAllMachines,
  updateMachineStatus,
  updateMachinePerformance,
  deleteMachine,
} from "../repositories/machine.repository.js";

import {
  VALID_MACHINE_STATUSES,
} from "../constants/machine.constants.js";
import { AppError } from "../../../utils/AppError.js";

/*
=================================
CREATE MACHINE
=================================
*/

export async function createMachineService(machine_no) {

  if (!machine_no) {
    throw new AppError("machine_no required", 400);
  }

  return await createMachine(machine_no);
}

/*
=================================
GET MACHINES
=================================
*/

export async function getMachinesService() {

  const machines = await getAllMachines();

  return machines.map((m) => {

    const kg24h = m.kg_per_hour * 24;

    const estimatedRolls =
      m.roll_size > 0
        ? Math.floor(kg24h / m.roll_size)
        : 0;

    return {
      ...m,
      kg_24h: kg24h,
      estimated_rolls_24h: estimatedRolls,
    };
  });
}

/*
=================================
UPDATE STATUS
=================================
*/

export async function updateMachineStatusService(id, status) {

  if (!VALID_MACHINE_STATUSES.includes(status)) {
    throw new AppError("Invalid status", 400);
  }

  return await updateMachineStatus(id, status);
}

/*
=================================
UPDATE PERFORMANCE
=================================
*/

export async function updateMachinePerformanceService(
  id,
  rpm,
  counter,
  roll_size
) {

  if (counter == 0) {
    throw new AppError("Counter cannot be zero", 400);
  }

  return await updateMachinePerformance(
    id,
    rpm,
    counter,
    roll_size
  );
}

/*
=================================
DELETE MACHINE
=================================
*/

export async function deleteMachineService(id) {
  return await deleteMachine(id);
}