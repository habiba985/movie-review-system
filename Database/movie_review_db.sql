CREATE DATABASE IF NOT EXISTS movie_review_db;
USE movie_review_db;

CREATE TABLE Users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('user','admin')      NOT NULL DEFAULT 'user',
    status        ENUM('active','blocked')  NOT NULL DEFAULT 'active',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Directors (
    director_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    nationality VARCHAR(50),
    birth_year  INT
);

CREATE TABLE Movies (
    movie_id     INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    release_year INT NOT NULL,
    duration_min INT NOT NULL CHECK (duration_min > 0),
    description  TEXT,
    poster_url   VARCHAR(255),
    director_id  INT NOT NULL,
    FOREIGN KEY (director_id) REFERENCES Directors(director_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Genres (
    genre_id   INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Movie_Genres (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Reviews (
    review_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    movie_id    INT NOT NULL,
    rating      TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 10),
    comment     TEXT,
    status      ENUM('visible','hidden') NOT NULL DEFAULT 'visible',
    review_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, movie_id),
    FOREIGN KEY (user_id)  REFERENCES Users(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
INSERT INTO Users (name, email, password_hash, role) VALUES
('Admin Habiba', 'admin@moviereview.com', 'hash_admin_123', 'admin'),
('Rahim Uddin',  'rahim@example.com',     'hash_rahim_123', 'user'),
('Sadia Islam',  'sadia@example.com',     'hash_sadia_123', 'user'),
('Tanvir Ahmed', 'tanvir@example.com',    'hash_tanvir_123','user'),
('Mim Akter',    'mim@example.com',       'hash_mim_123',   'user');

INSERT INTO Directors (name, nationality, birth_year) VALUES
('Christopher Nolan', 'British-American', 1970),
('Bong Joon-ho',      'South Korean',     1969),
('Rajkumar Hirani',   'Indian',           1962),
('Frank Darabont',    'American',         1959);

INSERT INTO Genres (genre_name) VALUES
('Action'), ('Drama'), ('Sci-Fi'), ('Thriller'), ('Comedy');

INSERT INTO Movies (title, release_year, duration_min, description, poster_url, director_id) VALUES
('Inception', 2010, 148, 'A thief enters people''s dreams to steal secrets.', 'posters/inception.jpg', 1),
('Interstellar', 2014, 169, 'Astronauts travel through a wormhole to save humanity.', 'posters/interstellar.jpg', 1),
('Parasite', 2019, 132, 'A poor family infiltrates a wealthy household.', 'posters/parasite.jpg', 2),
('3 Idiots', 2009, 170, 'Three engineering students challenge the education system.', 'posters/3idiots.jpg', 3),
('The Shawshank Redemption', 1994, 142, 'Two prisoners form a friendship over many years.', 'posters/shawshank.jpg', 4);

INSERT INTO Movie_Genres (movie_id, genre_id) VALUES
(1,1),(1,3),(1,4),
(2,2),(2,3),
(3,2),(3,4),
(4,2),(4,5),
(5,2);

INSERT INTO Reviews (user_id, movie_id, rating, comment) VALUES
(2, 1, 9,  'Mind-blowing story and great visuals.'),
(3, 1, 8,  'A bit confusing but amazing.'),
(4, 1, 10, 'My all-time favourite.'),
(2, 2, 9,  'Emotional and visually stunning.'),
(3, 3, 10, 'A masterpiece with a sharp message.'),
(5, 3, 9,  'Very unpredictable.'),
(4, 4, 9,  'Funny and inspiring.'),
(5, 4, 8,  'Loved the friendship theme.'),
(2, 5, 10, 'Perfect storytelling.');

SELECT m.title, m.release_year, d.name AS director,
       GROUP_CONCAT(g.genre_name SEPARATOR ', ') AS genres
FROM Movies m
JOIN Directors d        ON m.director_id = d.director_id
JOIN Movie_Genres mg    ON m.movie_id = mg.movie_id
JOIN Genres g           ON mg.genre_id = g.genre_id
GROUP BY m.movie_id, m.title, m.release_year, d.name;

SELECT m.title, ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM Movies m
JOIN Reviews r ON m.movie_id = r.movie_id
WHERE r.status = 'visible'
GROUP BY m.movie_id, m.title;

SELECT m.title, ROUND(AVG(r.rating),2) AS avg_rating
FROM Movies m
JOIN Reviews r ON m.movie_id = r.movie_id
WHERE r.status = 'visible'
GROUP BY m.movie_id, m.title
ORDER BY avg_rating DESC
LIMIT 3;

SELECT title, release_year FROM Movies WHERE title LIKE '%inter%';

SELECT m.title, m.release_year
FROM Movies m
JOIN Movie_Genres mg ON m.movie_id = mg.movie_id
JOIN Genres g        ON mg.genre_id = g.genre_id
WHERE g.genre_name = 'Sci-Fi';

SELECT u.name, r.rating, r.comment, r.review_date
FROM Reviews r
JOIN Users u ON r.user_id = u.user_id
WHERE r.movie_id = 1 AND r.status = 'visible'
ORDER BY r.review_date DESC;

SELECT m.title, r.rating, r.comment, r.review_date
FROM Reviews r
JOIN Movies m ON r.movie_id = m.movie_id
WHERE r.user_id = 2;

SELECT m.title
FROM Movies m
LEFT JOIN Reviews r ON m.movie_id = r.movie_id
WHERE r.review_id IS NULL;

SELECT u.name, COUNT(r.review_id) AS total_reviews
FROM Users u
JOIN Reviews r ON u.user_id = r.user_id
GROUP BY u.user_id, u.name
ORDER BY total_reviews DESC;

SELECT g.genre_name, COUNT(mg.movie_id) AS total_movies
FROM Genres g
LEFT JOIN Movie_Genres mg ON g.genre_id = mg.genre_id
GROUP BY g.genre_id, g.genre_name;

UPDATE Reviews SET status = 'hidden'  WHERE review_id = 3;
UPDATE Users   SET status = 'blocked' WHERE user_id = 4;

USE movie_review_db;

SELECT 'Users' AS userstable_name, COUNT(*) AS total FROM Users
UNION ALL SELECT 'Directors', COUNT(*) FROM Directors
UNION ALL SELECT 'Movies', COUNT(*) FROM Movies
UNION ALL SELECT 'Genres', COUNT(*) FROM Genres
UNION ALL SELECT 'Movie_Genres', COUNT(*) FROM Movie_Genres
UNION ALL SELECT 'Reviews', COUNT(*) FROM Reviews;

UPDATE Reviews 
SET status = 'hidden' 
WHERE review_id = 3;

UPDATE Users 
SET status = 'blocked' 
WHERE user_id = 4;

SELECT * FROM Reviews;
SELECT * FROM Users;

UPDATE Reviews 
SET status = 'visible' 
WHERE review_id = 3;

UPDATE Users 
SET status = 'active' 
WHERE user_id = 4;

SELECT * FROM Reviews;
SELECT * FROM Users;