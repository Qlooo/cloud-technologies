# Практическая работа №1 — Flask Todo

Исходный проект:
https://github.com/patrickloeber/flask-todo

Исходный commit:
60c7fee15c738c2d8c4460e21f10d87f89c9aaf9

В исходной версии нет Dockerfile, Compose и Kubernetes-манифестов.

## Запуск

Требуются Docker Engine и Docker Compose.

Из корня клонированного репозитория:
docker compose up

Настройки по умолчанию:
- внешний адрес: http://127.0.0.1:8080
- внутренний порт контейнера: 5000
- уровень журналирования Gunicorn: info

Для собственных настроек:
cp .env.example .env

.env не включается в Git.

## Хранение данных

SQLite находится в /app/instance/db.sqlite.
Каталог /app/instance подключён к именованному тому todo_data.
При первом запуске таблицы создаёт wsgi.py.

## Проверка

docker compose ps
docker compose logs --tail=30 app
curl -I http://127.0.0.1:8080/

## Доступ через SSH с другого компьютера

ssh -N -L 18080:127.0.0.1:8080 USER@SERVER_IP

Затем открыть в браузере:
http://127.0.0.1:18080
