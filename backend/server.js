require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/api/movies', require('./routes/movies'));
app.use('/api/genres', require('./routes/genres'));
app.use('/api/directors', require('./routes/directors'));
app.use('/api/auth', require('./routes/auth'));
// app.use('/api', require('./routes/auth'));
// app.use('/cid', require('./routes/cid'));


app.get('/api/health', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT COUNT(*) AS total FROM Movies');
    res.json({ status: 'OK', movies: rows[0].total });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: 'ERROR', message: err.message });
  }
});

app.get('/info', async (req, res) => {
    res.status(200).json({ status: 'success', message: 'successfully retrieved!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
