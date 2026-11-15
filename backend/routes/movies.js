const express = require('express');
const router = express.Router();
const db = require('../db');

const MOVIE_FIELDS = `
  m.movie_id, m.title, m.release_year, m.duration_min,
  m.description, m.poster_url,
  d.name AS director,
  (SELECT GROUP_CONCAT(g.genre_name SEPARATOR ', ')
     FROM Movie_Genres mg
     JOIN Genres g ON mg.genre_id = g.genre_id
    WHERE mg.movie_id = m.movie_id) AS genres,
  (SELECT ROUND(AVG(r.rating), 1)
     FROM Reviews r
    WHERE r.movie_id = m.movie_id AND r.status = 'visible') AS avg_rating,
  (SELECT COUNT(*)
     FROM Reviews r
    WHERE r.movie_id = m.movie_id AND r.status = 'visible') AS total_reviews
`;

router.get('/', async (req, res) => {
  try {
    const { search, genre } = req.query;

    let sql = `
      SELECT ${MOVIE_FIELDS}
      FROM Movies m
      JOIN Directors d ON m.director_id = d.director_id
      WHERE 1 = 1`;
    const params = [];

    if (search) {
      sql += ' AND m.title LIKE ?';
      params.push(`%${search}%`);
    }

    if (genre) {
      sql += `
        AND EXISTS (
          SELECT 1
            FROM Movie_Genres mg2
            JOIN Genres g2 ON mg2.genre_id = g2.genre_id
           WHERE mg2.movie_id = m.movie_id AND g2.genre_name = ?)`;
      params.push(genre);
    }

    sql += ' ORDER BY m.title';

    const [rows] = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT ${MOVIE_FIELDS}
         FROM Movies m
         JOIN Directors d ON m.director_id = d.director_id
        WHERE m.movie_id = ?`,
      [req.params.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Movie not found' });
    }
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});
router.put('/:id', async (req, res) => {
  const { title, release_year, duration_min, description, poster_url, director_id, genre_ids } = req.body;

  if (!title || !release_year || !duration_min || !director_id) {
    return res.status(400).json({
      message: 'title, release_year, duration_min and director_id are required'
    });
  }

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [result] = await conn.query(
      `UPDATE Movies
          SET title = ?, release_year = ?, duration_min = ?,
              description = ?, poster_url = ?, director_id = ?
        WHERE movie_id = ?`,
      [title, release_year, duration_min, description || null,
       poster_url || null, director_id, req.params.id]
    );

    if (result.affectedRows === 0) {
      await conn.rollback();
      return res.status(404).json({ message: 'Movie not found' });
    }

    if (Array.isArray(genre_ids)) {
      await conn.query('DELETE FROM Movie_Genres WHERE movie_id = ?', [req.params.id]);
      for (const genreId of genre_ids) {
        await conn.query(
          'INSERT INTO Movie_Genres (movie_id, genre_id) VALUES (?, ?)',
          [req.params.id, genreId]
        );
      }
    }

    await conn.commit();
    res.json({ message: 'Movie updated' });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ message: err.message });
  } finally {
    conn.release();
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query(
      'DELETE FROM Movies WHERE movie_id = ?',
      [req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Movie not found' });
    }
    res.json({ message: 'Movie deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});
module.exports = router;
router.post('/', async (req, res) => {
  const { title, release_year, duration_min, description, poster_url, director_id, genre_ids } = req.body;

  if (!title || !release_year || !duration_min || !director_id) {
    return res.status(400).json({
      message: 'title, release_year, duration_min and director_id are required'
    });
  }

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [result] = await conn.query(
      `INSERT INTO Movies (title, release_year, duration_min, description, poster_url, director_id)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [title, release_year, duration_min, description || null, poster_url || null, director_id]
    );
    const movieId = result.insertId;

    if (Array.isArray(genre_ids)) {
      for (const genreId of genre_ids) {
        await conn.query(
          'INSERT INTO Movie_Genres (movie_id, genre_id) VALUES (?, ?)',
          [movieId, genreId]
        );
      }
    }

    await conn.commit();
    res.status(201).json({ message: 'Movie added', movie_id: movieId });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ message: err.message });
  } finally {
    conn.release();
  }
});