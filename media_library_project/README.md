# Личная медиатека (Personal Media Library)

## Описание предметной области
Проект предназначен для организации личной коллекции фильмов, сериалов, книг, музыки и игр.

## Группа
MnK - 362

## ФИО студента
Кушниренко Ульяна Николаевна

## Структура базы данных
- `media_items` – ядро системы (110+ записей)
- `genres` – жанры (22 записи)
- `content_types` – типы контента

## Как развернуть
1. Установите Microsoft SQL Server
2. Выполните скрипт database.sql в SSMS
3. База данных media_library создастся автоматически

## Ссылка на репозиторий
https://github.com/[https://github.com/MumbiLi/code-sanctuary]/personal-media-library-db

## Практическая работа №15: Интеграция мультимедиа (BLOB)

### Изменения в структуре БД
- В таблицу `media_items` добавлено поле `image` типа `VARBINARY(MAX)`

### Тестовые данные
- Для записей с id = 1-5 добавлены тестовые BLOB-данные

### SQL-код изменений
```sql
ALTER TABLE dbo.media_items ADD image VARBINARY(MAX) NULL;
UPDATE dbo.media_items SET image = CAST('ПР15 тест' AS VARBINARY(MAX)) WHERE id IN (1,2,3,4,5);


