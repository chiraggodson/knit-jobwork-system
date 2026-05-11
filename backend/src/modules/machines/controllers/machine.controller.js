import {
  createMachineService,
  getMachinesService,
  updateMachineStatusService,
  updateMachinePerformanceService,
  deleteMachineService,
} from "../services/machine.service.js";
import {
  successResponse,
} from "../../../utils/apiResponse.js";
/*
=================================
CREATE MACHINE
=================================
*/

export async function createMachineController(req, res, next) {
  try {

    const { machine_no } = req.body;

    const machine = await createMachineService(machine_no);

    return successResponse(
    res,
    machine,
    "Machine created",
    201
  );

  } catch (error) {
    next(error);
  }
}

/*
=================================
GET ALL MACHINES
=================================
*/

export async function getMachinesController(req, res, next) {
  try {

    const machines = await getMachinesService();

    return successResponse(
    res,
    machines,
    "Machines fetched"
  );

  } catch (error) {
    next(error);
  }
}

/*
=================================
UPDATE STATUS
=================================
*/

export async function updateMachineStatusController(
  req,
  res,
  next
) {
  try {

    const { id } = req.params;
    const { status } = req.body;

    const machine = await updateMachineStatusService(
      id,
      status
    );

    res.json(machine);

  } catch (error) {
    next(error);
  }
}

/*
=================================
UPDATE PERFORMANCE
=================================
*/

export async function updateMachinePerformanceController(
  req,
  res,
  next
) {
  try {

    const { id } = req.params;
    const { rpm, counter, roll_size } = req.body;

    const machine =
      await updateMachinePerformanceService(
        id,
        rpm,
        counter,
        roll_size
      );

    return successResponse(
  res,
  machine,
  "Machine updated"
);

  } catch (error) {
    next(error);
  }
}

/*
=================================
DELETE MACHINE
=================================
*/

export async function deleteMachineController(
  req,
  res,
  next
) {
  try {

    const { id } = req.params;

    await deleteMachineService(id);

    res.json({
  success: true,
  message: "Machine deleted",
});

  } catch (error) {
    next(error);
  }
}