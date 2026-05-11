import { pool } from "../../../db.js";

/*
=================================
CREATE YARN CHALLAN
=================================
*/

export const createYarnChallan = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      challan_no,
      challan_type,
      party_id,
      challan_date,
      vehicle_no,
      remarks,
      items,
    } = req.body;

    /*
    =================================
    VALIDATION
    =================================
    */

    if (!challan_no) {
      return res.status(400).json({
        success: false,
        message: "Challan number is required",
      });
    }

    if (!party_id) {
      return res.status(400).json({
        success: false,
        message: "Party is required",
      });
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: "At least one yarn item is required",
      });
    }

    /*
    =================================
    BEGIN TRANSACTION
    =================================
    */

    await client.query("BEGIN");

    /*
    =================================
    INSERT CHALLAN HEADER
    =================================
    */

    const challanQuery = `
      INSERT INTO yarn_challans (
        challan_no,
        challan_type,
        party_id,
        challan_date,
        vehicle_no,
        remarks
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;

    const challanValues = [
      challan_no,
      challan_type || "INWARD",
      party_id,
      challan_date,
      vehicle_no || null,
      remarks || null,
    ];

    const challanResult = await client.query(
      challanQuery,
      challanValues
    );

    const challanId = challanResult.rows[0].id;

    /*
    =================================
    INSERT CHALLAN ITEMS
    =================================
    */

    for (const item of items) {
      const itemQuery = `
        INSERT INTO yarn_challan_items (
          challan_id,
          yarn_id,
          color_id,
          bags,
          cones,
          gross_weight,
          tare_weight,
          net_weight,
          rate,
          remarks
        )
        VALUES (
          $1,$2,$3,$4,$5,
          $6,$7,$8,$9,$10
        )
      `;

      const itemValues = [
        challanId,
        item.yarn_id,
        item.color_id || null,
        item.bags || 0,
        item.cones || 0,
        item.gross_weight || 0,
        item.tare_weight || 0,
        item.net_weight || 0,
        item.rate || 0,
        item.remarks || null,
      ];

      await client.query(itemQuery, itemValues);
    }

    /*
    =================================
    COMMIT
    =================================
    */

    await client.query("COMMIT");

    return res.status(201).json({
      success: true,
      message: "Yarn challan created successfully",
      challan_id: challanId,
    });

  } catch (error) {

    /*
    =================================
    ROLLBACK
    =================================
    */

    await client.query("ROLLBACK");

    console.error("CREATE YARN CHALLAN ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create yarn challan",
      error: error.message,
    });

  } finally {
    client.release();
  }
};