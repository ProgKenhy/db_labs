# INSERT INTO имя_таблицы [(имя_столбца [, ...])]
# VALUES (выражение [, ...]) [, ...]

-- 1) Добавление языков
INSERT INTO language (ID, NAME)
VALUES ('ru', 'Русский'),
	   ('en', 'Английский'),
	   ('kz', 'Казахский');

-- 2) Добавление ролей
INSERT INTO role (NAME)
VALUES ('Актёр'),
	   ('Режиссёр'),
	   ('Каскадёр');

ALTER TABLE movie
	MODIFY RELEASE_YEAR SMALLINT NOT NULL CHECK (RELEASE_YEAR >= 1888);
-- 3) Добавление фильмов
INSERT INTO movie (RELEASE_YEAR, LENGTH, MIN_AGE, RATING)
VALUES (1900, 500, 21, 8.5),
	   (1990, 200, 0, 3.5);

-- 4) Добавление людей (без отчества)
INSERT INTO person (FIRST_NAME, MIDDLE_NAME)
VALUES ('Дима', 'Валуев'),
	   ('Миша', 'Горбачёв');

-- 5) Добавление заголовков фильмов
INSERT INTO movie_title (LANGUAGE_ID, MOVIE_ID, TITLE)
VALUES ('ru', 1, 'Герои'),
	   ('en', 1, 'Heroes'),
	   ('ru', 2, 'Творцы');

# INSERT INTO имя_таблицы [(имя_столбца [, ...])] SELECT …

-- 1) Создание и заполнение таблицы популярных фильмов
CREATE TABLE popular_movies
(
	movie_id     INT PRIMARY KEY,
	title_ru     VARCHAR(500),
	release_year SMALLINT,
	rating       DECIMAL(3, 1)
);

INSERT INTO popular_movies (movie_id, title_ru, release_year, rating)
SELECT m.id, mt.TITLE, m.RELEASE_YEAR, m.RATING
FROM movie m
		 JOIN movie_title mt ON m.ID = mt.MOVIE_ID
WHERE RATING >= 8
  AND mt.LANGUAGE_ID = 'ru';

-- 2) Создание и заполнение таблицы многоязычных фильмов
CREATE TABLE multilingual_movies
(
	movie_id     INT PRIMARY KEY,
	title_ru     VARCHAR(500),
	title_en     VARCHAR(500),
	release_year SMALLINT
);

INSERT INTO multilingual_movies (movie_id, title_ru, title_en, release_year)
SELECT m.ID, mt1.TITLE, mt2.TITLE, m.RELEASE_YEAR
FROM movie m
		 JOIN movie_title mt1 ON m.ID = mt1.MOVIE_ID and mt1.LANGUAGE_ID = 'ru'
		 JOIN movie_title mt2 ON m.ID = mt2.MOVIE_ID and mt2.LANGUAGE_ID = 'en';

-- 3) Создание и заполнение таблицы годовой статистики
CREATE TABLE year_statistics
(
	year               SMALLINT PRIMARY KEY,
	movies_count       INT,
	avg_length         DECIMAL(6, 1),
	avg_rating         DECIMAL(3, 1),
	title_ru_top_movie VARCHAR(500)
);

INSERT INTO year_statistics (year, movies_count, avg_length, avg_rating, title_ru_top_movie)
SELECT m.RELEASE_YEAR as year,
	   COUNT(DISTINCT m.ID),
	   ROUND(AVG(m.LENGTH)),
	   ROUND(AVG(m.RATING), 1),
	   (SELECT mt.TITLE
		FROM movie m
		JOIN movie_title mt ON m.ID = mt.MOVIE_ID and mt.LANGUAGE_ID = 'ru'
		WHERE m.RELEASE_YEAR = year
		ORDER BY m.RATING DESC
		LIMIT 1)
FROM movie m
GROUP BY m.RELEASE_YEAR;


-- 4)
