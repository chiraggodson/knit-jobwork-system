import { pool } from "../../../db.js";

/*
=================================
CREATE MACHINE
=================================
*/

export async function createMachine(machine_no) {
  const result = await pool.query(
    `
    INSERT INTO machines (machine_no)
    VALUES ($1)
    RETURNING *
    `,
    [machine_no]
  );

  return result.rows[0];
}

/*
=================================
GET ALL MACHINES
=================================
*/

export async function getAllMachines() {
  const result = await pool.query(`
    SELECT
      m.id,
      m.machine_no,
      m.status,
      m.rpm,
      m.counter,
      m.roll_size,

      COALESCE(
        (COALESCE(m.rpm,0) * 60) /
        NULLIF(COALESCE(m.counter,1),0)
      ,0)::float AS kg_per_hour

    FROM machines m
    ORDER BY m.machine_no::int;
  `);

  return result.rows;
}

/*
=================================
UPDATE MACHINE STATUS
=================================
*/

export async function updateMachineStatus(id, status) {
  const result = await pool.query(
    `
    UPDATE machines
    SET status = $1
    WHERE id = $2
    RETURNING *
    `,
    [status, id]
  );

  return result.rows[0];
}

/*
=================================
UPDATE MACHINE PERFORMANCE
=================================
*/

export async function updateMachinePerformance(
  id,
  rpm,
  counter,
  roll_size
) {
  const result = await pool.query(
    `
    UPDATE machines
    SET rpm = $1,
        counter = $2,
        roll_size = $3
    WHERE id = $4
    RETURNING *
    `,
    [rpm ?? 0, counter ?? 1, roll_size ?? 0, id]
  );

  return result.rows[0];
}

/*
=================================
DELETE MACHINE
=================================
*/

export async function deleteMachine(id) {
  await pool.query(
    `
    DELETE FROM machines
    WHERE id = $1
    `,
    [id]
  );
}