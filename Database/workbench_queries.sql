-- Workbench queries used while building the Movie Review System
-- Run movie_review_db.sql first (creates tables and sample data).

USE movie_review_db;

-- View all table data
SELECT * FROM movie_review_db.users;
SELECT * FROM movie_review_db.genres;
SELECT * FROM movie_review_db.movie_genres;
SELECT * FROM movie_review_db.directors;
SELECT * FROM movie_review_db.movies;
SELECT * FROM movie_review_db.reviews;

-- Restore review and user status after testing
UPDATE Reviews SET status = 'visible' WHERE review_id = 3;
UPDATE Users   SET status = 'active'  WHERE user_id = 4;

SELECT review_id, status FROM Reviews;

-- Check users (login / role testing)
SELECT user_id, name, email, password_hash, role FROM Users;
SELECT user_id, name, email, role FROM Users;

-- Make a registered user an admin (change user_id as needed)
UPDATE Users SET role = 'admin' WHERE user_id = 6;
SELECT user_id, name, email, role FROM Users;

-- Reset the Inception movie data
UPDATE Movies
   SET title = 'Inception',
       release_year = 2010,
       duration_min = 148,
       description = 'A thief enters people''s dreams to steal secrets.',
       poster_url = 'posters/inception.jpg',
       director_id = 1
 WHERE movie_id = 1;

SELECT movie_id, title, release_year, duration_min, director_id FROM Movies;
