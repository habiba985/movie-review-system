const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/directors → সব director
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT director_id, name FROM Directors ORDER BY name'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;