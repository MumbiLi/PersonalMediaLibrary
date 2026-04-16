-- =====================================================
-- Практическая работа №13. Вариант 7. Личная медиатека
-- Автор: Кушниренко Ульяна Николаевна, группа MnK - 362
-- =====================================================

-- 1. Удаление старой БД (если есть)
DROP DATABASE IF EXISTS media_library;
CREATE DATABASE media_library CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE media_library;

-- 2. Создание таблиц (схема)
CREATE TABLE genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE content_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(30) NOT NULL UNIQUE  -- 'movie', 'tv_series', 'book', 'music', 'game'
);

CREATE TABLE platforms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    type ENUM('streaming', 'physical', 'digital_store') NOT NULL
);

CREATE TABLE people (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    birth_year INT
);

CREATE TABLE media_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    original_title VARCHAR(200),
    content_type_id INT NOT NULL,
    release_year INT,
    duration_minutes INT,          -- для фильмов/серий/музыки
    total_episodes INT,            -- для сериалов
    total_pages INT,               -- для книг
    description TEXT,
    cover_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_type_id) REFERENCES content_types(id)
);

-- Связь многие-ко-многим: медиаобъекты - жанры
CREATE TABLE media_genres (
    media_id INT,
    genre_id INT,
    PRIMARY KEY (media_id, genre_id),
    FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- Связь: медиаобъекты - люди (режиссёры, авторы, актёры)
CREATE TABLE media_people (
    media_id INT,
    person_id INT,
    role ENUM('director', 'author', 'actor', 'composer') NOT NULL,
    FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE,
    PRIMARY KEY (media_id, person_id, role)
);

-- Связь: медиаобъекты - платформы (где доступно)
CREATE TABLE media_platforms (
    media_id INT,
    platform_id INT,
    url VARCHAR(500),
    price DECIMAL(10,2),
    PRIMARY KEY (media_id, platform_id),
    FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(id) ON DELETE CASCADE
);

-- Таблица статусов просмотра/прочтения
CREATE TABLE watch_statuses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(30) NOT NULL UNIQUE  -- 'want', 'in_progress', 'completed', 'abandoned'
);

-- Основная таблица фактов: личный прогресс пользователя
CREATE TABLE user_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    media_id INT NOT NULL,
    status_id INT NOT NULL,
    user_rating DECIMAL(2,1) CHECK (user_rating >= 0 AND user_rating <= 10),
    review TEXT,
    progress_value INT DEFAULT 0,   -- просмотренные эпизоды/прочитанные страницы/часы
    started_at DATE,
    completed_at DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES watch_statuses(id)
);

-- 3. Создание ролей и пользователей
DROP ROLE IF EXISTS 'app_user', 'app_manager', 'app_admin';
CREATE ROLE 'app_user', 'app_manager', 'app_admin';

-- Права для Пользователя (только чтение и свой прогресс)
GRANT SELECT ON media_library.* TO 'app_user';
GRANT INSERT, UPDATE, DELETE ON media_library.user_progress TO 'app_user';

-- Менеджер (может добавлять/изменять медиаобъекты, жанры, людей)
GRANT SELECT, INSERT, UPDATE, DELETE ON media_library.* TO 'app_manager';
REVOKE DELETE ON media_library.user_progress FROM 'app_manager'; -- не удаляет чужие прогрессы

-- Администратор (полный доступ)
GRANT ALL PRIVILEGES ON media_library.* TO 'app_admin' WITH GRANT OPTION;

-- Создаём пользователей (пароли для примера)
CREATE USER IF NOT EXISTS 'user1'@'%' IDENTIFIED BY 'user123';
CREATE USER IF NOT EXISTS 'manager1'@'%' IDENTIFIED BY 'manager123';
CREATE USER IF NOT EXISTS 'admin1'@'%' IDENTIFIED BY 'admin123';

GRANT 'app_user' TO 'user1'@'%';
GRANT 'app_manager' TO 'manager1'@'%';
GRANT 'app_admin' TO 'admin1'@'%';

FLUSH PRIVILEGES;

-- 4. Заполнение справочников (минимум 20 записей в ключевых)
INSERT INTO genres (name, description) VALUES
('Драма', 'Серьёзные, эмоциональные сюжеты'), ('Комедия', 'Юмор, развлечение'),
('Фантастика', 'Научная фантастика, космос'), ('Фэнтези', 'Магия, вымышленные миры'),
('Триллер', 'Напряжение, саспенс'), ('Ужасы', 'Хоррор, страшные истории'),
('Детектив', 'Расследования преступлений'), ('Приключения', 'Путешествия, экшн'),
('Романтика', 'Любовная линия'), ('Документальный', 'Реальные события'),
('Биография', 'Жизнь известных людей'), ('Исторический', 'Исторические события'),
('Криминал', 'Гангстерские истории'), ('Мелодрама', 'Чувственные переживания'),
('Аниме', 'Японская анимация'), ('Постапокалипсис', 'После конца света'),
('Киберпанк', 'Высокие технологии, антиутопия'), ('Ситком', 'Ситуационная комедия'),
('Нуар', 'Тёмный стиль, цинизм'), ('Психологический', 'Глубокие характеры'),
('Мюзикл', 'Музыкальные номера'), ('Вестерн', 'Дикий Запад');

INSERT INTO content_types (type_name) VALUES ('movie'), ('tv_series'), ('book'), ('music_album'), ('game');

INSERT INTO platforms (name, type) VALUES
('Netflix', 'streaming'), ('Amazon Prime', 'streaming'), ('HBO Max', 'streaming'),
('Disney+', 'streaming'), ('Apple TV+', 'streaming'), ('YouTube', 'streaming'),
('Steam', 'digital_store'), ('Epic Games', 'digital_store'), ('PlayStation Store', 'digital_store'),
('Blu-ray Disc', 'physical'), ('DVD', 'physical'), ('CD', 'physical'),
('Audible', 'digital_store'), ('Google Play Books', 'digital_store'), ('Spotify', 'streaming'),
('Apple Music', 'streaming'), ('Bookmate', 'digital_store'), ('IVI', 'streaming'),
('Кинопоиск', 'streaming'), ('Premier', 'streaming');

INSERT INTO watch_statuses (status_name) VALUES ('want'), ('in_progress'), ('completed'), ('abandoned');

-- Люди (режиссёры, авторы, актёры)
INSERT INTO people (full_name, birth_year) VALUES
('Кристофер Нолан', 1970), ('Дени Вильнёв', 1967), ('Грета Гервиг', 1983),
('Стивен Кинг', 1947), ('Джордж Р. Р. Мартин', 1948), ('Дж. К. Роулинг', 1965),
('Хидео Кодзима', 1963), ('Тодд Ховард', 1970), ('Ханс Циммер', 1957),
('Леонардо ДиКаприо', 1974), ('Скарлетт Йоханссон', 1984), ('Киану Ривз', 1964);

-- 5. Заполнение ядра БД (media_items) – 120+ записей
INSERT INTO media_items (title, original_title, content_type_id, release_year, duration_minutes, total_episodes, total_pages, description) VALUES
('Интерстеллар', 'Interstellar', 1, 2014, 169, NULL, NULL, 'Путешествие через червоточину'),
('Начало', 'Inception', 1, 2010, 148, NULL, NULL, 'Внедрение идей в сны'),
('Дюна', 'Dune', 1, 2021, 155, NULL, NULL, 'Эпическая фантастика'),
('Барби', 'Barbie', 1, 2023, 114, NULL, NULL, 'Комедийное приключение'),
('Сияние', 'The Shining', 1, 1980, 146, NULL, NULL, 'Ужасы в отеле'),
('Острые козырьки', 'Peaky Blinders', 2, 2013, 60, 36, NULL, 'Гангстеры Бирмингема'),
('Игра престолов', 'Game of Thrones', 2, 2011, 55, 73, NULL, 'Битва за Железный трон'),
('Ведьмак', 'The Witcher', 2, 2019, 60, 24, NULL, 'Охота на монстров'),
('1984', 'Nineteen Eighty-Four', 3, 1949, NULL, NULL, 328, 'Антиутопия Оруэлла'),
('Марсианин', 'The Martian', 3, 2014, NULL, NULL, 384, 'Выживание на Марсе'),
('Harry Potter and Sorcerer Stone', NULL, 3, 1997, NULL, NULL, 320, 'Философский камень'),
('The Last of Us Part II', NULL, 5, 2020, NULL, NULL, NULL, 'Постапокалиптический экшен'),
('Cyberpunk 2077', NULL, 5, 2020, NULL, NULL, NULL, 'Открытый мир будущего'),
('Elden Ring', NULL, 5, 2022, NULL, NULL, NULL, 'Фэнтези RPG'),
('Thriller', NULL, 4, 1982, 42, NULL, NULL, 'Альбом Майкла Джексона'),
('Dark Side of the Moon', NULL, 4, 1973, 43, NULL, NULL, 'Pink Floyd');

-- ГЕНЕРАЦИЯ 100 КРАСИВЫХ НАЗВАНИЙ (вместо "Медиаобъект")
INSERT INTO media_items (title, content_type_id, release_year, description) VALUES
('Космическая одиссея', 1, 2015, 'Научно-фантастический фильм'),
('Последний самурай', 1, 2003, 'Эпическая драма'),
('Король Лев', 1, 1994, 'Диснеевский шедевр'),
('Алита', 1, 2019, 'Киберпанк-боевик'),
('Трон Наследие', 1, 2010, 'Киберпанк-фантастика'),
('Облачный атлас', 1, 2012, 'Философская драма'),
('Безумный Макс', 1, 2015, 'Постапокалипсис'),
('Грань будущего', 1, 2014, 'Фантастический боевик'),
('Трансформеры', 1, 2007, 'Роботы против людей'),
('Терминатор 2', 1, 1991, 'Классика фантастики'),
('Чужой', 1, 1979, 'Космический хоррор'),
('Хищник', 1, 1987, 'Экшен с Шварценеггером'),
('Робокоп', 1, 1987, 'Киберпанк-классика'),
('Звёздные войны', 1, 1977, 'Космическая сага'),
('Стартрек', 1, 2009, 'Космическое приключение'),
('Мстители Война бесконечности', 1, 2018, 'Марвел-эпопея'),
('Человек-паук', 1, 2002, 'Супергеройский фильм'),
('Железный человек', 1, 2008, 'Начало Марвел'),
('Тор', 1, 2011, 'Скандинавский бог'),
('Первый мститель', 1, 2011, 'Капитан Америка'),
('Доктор Стрэндж', 1, 2016, 'Магия в Марвел'),
('Чёрная пантера', 1, 2018, 'Ваканда навсегда'),
('Капитан Марвел', 1, 2019, 'Кэрол Дэнверс'),
('Шан-Чи', 1, 2021, 'Легенда десяти колец'),
('Вечные', 1, 2021, 'Марвел-философия'),
('Морбиус', 1, 2022, 'Живой вампир'),
('Мадагаскар', 1, 2005, 'Детская комедия'),
('Шрек', 1, 2001, 'Любимый огр'),
('Холодное сердце', 1, 2013, 'Диснеевская принцесса'),
('Зверополис', 1, 2016, 'Город животных'),
('Головоломка', 1, 2015, 'Эмоции внутри'),
('Тайна Коко', 1, 2017, 'Мексиканские традиции'),
('Душа', 1, 2020, 'Смысл жизни'),
('Лука', 1, 2021, 'Итальянское лето'),
('Я краснею', 1, 2022, 'Панда внутри'),
('Энканто', 1, 2021, 'Магическая семья'),
('Райя', 1, 2021, 'Дракон и воин'),
('Соник', 1, 2020, 'Синий ёжик'),
('Детектив Пикачу', 1, 2019, 'Покемоны в реальности'),
('Аватар 2', 1, 2022, 'Возвращение на Пандору'),
('Топ Ган Мэверик', 1, 2022, 'Лётчики возвращаются'),
('Дюна 2', 1, 2024, 'Продолжение эпопеи'),
('Оппенгеймер', 1, 2023, 'Создатель атомной бомбы'),
('Аквамен', 1, 2018, 'Властелин океана'),
('Шазам', 1, 2019, 'Супергерой-ребёнок'),
('Отряд самоубийц', 1, 2021, 'Злодеи спасают мир'),
('Чудо-женщина', 1, 2017, 'Амазонская принцесса'),
('Бэтмен', 1, 2022, 'Тёмный рыцарь возвращается'),
('Супермен', 1, 2013, 'Человек из стали'),
('Король Артур', 1, 2017, 'Меч в камне');

-- СЕРИАЛЫ (content_type_id = 2)
('Острые козырьки', 2, 2013, 'Гангстеры Бирмингема'),
('Игра престолов', 2, 2011, 'Битва за Железный трон'),
('Ведьмак', 2, 2019, 'Охота на монстров'),
('Во все тяжкие', 2, 2008, 'Учитель химии стал наркобароном'),
('Шерлок', 2, 2010, 'Современный детектив'),
('Друзья', 2, 1994, 'Классическая комедия'),
('Черное зеркало', 2, 2011, 'Антиутопия технологий'),
('Мандалорец', 2, 2019, 'Звёздные войны'),
('Викинги', 2, 2013, 'История Рагнара'),
('Секретные материалы', 2, 1993, 'Малдер и Скалли'),

-- КНИГИ (content_type_id = 3)
('1984', 3, 1949, 'Антиутопия Оруэлла'),
('Марсианин', 3, 2014, 'Выживание на Марсе'),
('Гарри Поттер и философский камень', 3, 1997, 'Первый курс Хогвартса'),
('Властелин колец', 3, 1954, 'Толкин'),
('Хоббит', 3, 1937, 'Путешествие Бильбо'),
('Преступление и наказание', 3, 1866, 'Достоевский'),
('Мастер и Маргарита', 3, 1967, 'Булгаков'),
('Три товарища', 3, 1936, 'Ремарк'),
('Сто лет одиночества', 3, 1967, 'Маркес'),
('Убить пересмешника', 3, 1960, 'Ли'),

-- МУЗЫКА (content_type_id = 4)
('Thriller', 4, 1982, 'Альбом Майкла Джексона'),
('Dark Side of the Moon', 4, 1973, 'Pink Floyd'),
('Abbey Road', 4, 1969, 'The Beatles'),
('Nevermind', 4, 1991, 'Nirvana'),
('Back in Black', 4, 1980, 'AC/DC'),
('Hotel California', 4, 1976, 'Eagles'),
('Rumours', 4, 1977, 'Fleetwood Mac'),
('Bad', 4, 1987, 'Майкл Джексон'),
('The Eminem Show', 4, 2002, 'Eminem'),
('Lemonade', 4, 2016, 'Beyonce'),

-- ИГРЫ (content_type_id = 5)
('The Last of Us Part II', 5, 2020, 'Постапокалиптический экшен'),
('Cyberpunk 2077', 5, 2020, 'Открытый мир будущего'),
('Elden Ring', 5, 2022, 'Фэнтези RPG'),
('The Witcher 3', 5, 2015, 'Охота на монстров'),
('Red Dead Redemption 2', 5, 2018, 'Дикий Запад'),
('God of War Ragnarok', 5, 2022, 'Скандинавский экшен'),
('GTA V', 5, 2013, 'Лос-Сантос'),
('Minecraft', 5, 2011, 'Кубический мир'),
('Fortnite', 5, 2017, 'Королевская битва'),
('Stray', 5, 2022, 'Кот-робот');

-- Генерируем ещё 100+ записей циклом (для реальной БД)
DELIMITER $$
CREATE PROCEDURE generate_media()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 104 DO
        INSERT INTO media_items (title, original_title, content_type_id, release_year, duration_minutes, description)
        VALUES (
            CONCAT('Медиаобъект ', i),
            CONCAT('Media Object ', i),
            (i % 5) + 1,
            1990 + (i % 33),
            90 + (i % 150),
            CONCAT('Автоматически сгенерированное описание для объекта ', i)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL generate_media();
DROP PROCEDURE generate_media;

-- Связываем медиа с жанрами (примеры)
INSERT INTO media_genres (media_id, genre_id)
SELECT m.id, g.id
FROM media_items m
CROSS JOIN genres g
WHERE m.title IN ('Интерстеллар', 'Начало', 'Дюна') AND g.name IN ('Фантастика', 'Драма')
LIMIT 10;

INSERT INTO media_people (media_id, person_id, role)
VALUES
(1, 1, 'director'), (2, 1, 'director'), (3, 2, 'director'),
(4, 3, 'director'), (5, 4, 'author'), (6, 5, 'author');

-- Прогресс пользователя (более 20 записей)
INSERT INTO user_progress (media_id, status_id, user_rating, review, progress_value, started_at, completed_at)
VALUES
(1, 3, 9.5, 'Шедевр Нолана', 169, '2024-01-10', '2024-01-10'),
(2, 3, 9.0, 'Запутанный сон', 148, '2024-02-01', '2024-02-01'),
(3, 2, NULL, 'Смотрю сейчас', 90, '2024-03-01', NULL),
(6, 2, 8.0, 'Интересные персонажи', 12, '2024-02-15', NULL),
(7, 3, 8.5, 'Финал слабоват', 73, '2023-12-01', '2024-01-20'),
(9, 1, NULL, 'Хочу прочитать', 0, NULL, NULL),
(10, 3, 8.2, 'Инженерный подход', 384, '2024-02-10', '2024-02-28'),
(11, 3, 9.2, 'Детство', 320, '2023-11-01', '2023-11-30'),
(12, 3, 9.8, 'Эмоционально тяжело', 25, '2024-01-05', '2024-01-09'),
(13, 2, 7.5, 'Патчи улучшили', 40, '2024-02-20', NULL),
(14, 1, NULL, 'В планах', 0, NULL, NULL),
(15, 3, 9.0, 'Король поп-музыки', 42, '2024-03-01', '2024-03-01'),
(16, 3, 10.0, 'Легендарный альбом', 43, '2023-12-15', '2023-12-15');

-- Добавим ещё 10 записей прогресса для разнообразия
INSERT INTO user_progress (media_id, status_id, user_rating, progress_value)
SELECT id, (id % 4) + 1, 5 + (id % 5), 10 + (id % 150)
FROM media_items
WHERE id BETWEEN 17 AND 26;

-- =============================================
-- ПРАКТИЧЕСКАЯ РАБОТА №15
-- Добавление BLOB-поля для хранения изображений
-- =============================================

-- Добавление поля image
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.media_items') AND name = 'image')
BEGIN
    ALTER TABLE dbo.media_items ADD image VARBINARY(MAX) NULL;
    PRINT 'Поле image добавлено';
END
ELSE
    PRINT 'Поле image уже существует';
GO

-- Заполнение тестовыми данными (для первых 5 записей)
UPDATE dbo.media_items 
SET image = CAST('ПР15 тестовые данные' AS VARBINARY(MAX)) 
WHERE id IN (1, 2, 3, 4, 5);
GO

-- Проверка результата
SELECT id, title, DATALENGTH(image) AS blob_size_bytes
FROM dbo.media_items
WHERE id <= 5;
GO