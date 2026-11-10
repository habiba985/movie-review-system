const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/genres  → সব genre
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT genre_id, genre_name FROM Genres ORDER BY genre_name'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;