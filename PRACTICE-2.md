# Практическая работа №2 — Kubernetes

## Приложение и окружение

Исходное приложение: https://github.com/patrickloeber/flask-todo
Репозиторий работы: https://github.com/Qlooo/cloud-technologies
Ветка: cloud-lab-2.

Учебный кластер kind работает локально на Ubuntu VPS:
4 CPU, 8 ГБ RAM, диск 80 ГБ.
kind: v0.33.0. Kubernetes и kubectl: v1.37.0.

Кластер: cloud-lab2.
Контекст: kind-cloud-lab2.
Namespace: cloud-lab2.
Образ приложения: flask-todo:1.0.0.
Deployment и Service: flask-todo.

## Файлы

- infra/kind.yaml — создание узла, подключение каталога и порта VPS.
- k8s/00-namespace.yaml — отдельное пространство имён.
- k8s/10-configmap.yaml — настройка Gunicorn.
- k8s/20-secret.yaml — локальный Secret, исключён из Git.
- infra/secret.example.yaml — пример структуры Secret без настоящего ключа.
- scripts/create-secret.py — создание локального Secret-файла.
- k8s/30-storage.yaml — PersistentVolume и PersistentVolumeClaim.
- k8s/40-deployment.yaml — две реплики приложения.
- k8s/50-service.yaml — NodePort Service.
- wsgi.py — загрузка настроек Flask из окружения и создание таблиц.

## Запуск в уже созданном кластере

В SSH на VPS, из корня проекта:

    kubectl config use-context kind-cloud-lab2
    kubectl config set-context --current --namespace=cloud-lab2
    python3 scripts/create-secret.py
    kubectl apply -f k8s/
    kubectl rollout status deployment/flask-todo --timeout=180s
    kubectl get nodes
    kubectl get pods
    kubectl get services
    kubectl get deployments
    kubectl get pvc
    curl --max-time 10 -I http://127.0.0.1:8081/

Образ flask-todo:1.0.0 должен быть заранее загружен в кластер.
Повторное выполнение create-secret.py сохраняет существующий ключ.

## Первоначальное развёртывание из Git

Этот раздел предназначен для нового развёртывания.
На работающей VPS повторно создавать существующий кластер не требуется.

Предварительно должны быть установлены Docker, kind v0.33.0,
kubectl v1.37.0, Git и Python 3.

    git clone --branch cloud-lab-2 https://github.com/Qlooo/cloud-technologies.git flask-todo-k8s
    cd flask-todo-k8s

Подготовить каталог данных на VPS:

    install -d -o 10001 -g 10001 -m 0750 /opt/cloud-practice/k8s-data/flask-todo

Создать кластер, если cloud-lab2 ещё не существует:

    KIND_EXPERIMENTAL_PROVIDER=docker kind create cluster --name cloud-lab2 --config infra/kind.yaml --image kindest/node:v1.37.0@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5 --wait 5m --retain

Проверить узел:

    kubectl version
    kubectl wait --for=condition=Ready nodes --all --timeout=180s
    kubectl get nodes

Подготовить образ и таблицы SQLite:

    docker build -t flask-todo:1.0.0 .
    docker run --rm --network none --mount type=bind,src=/opt/cloud-practice/k8s-data/flask-todo,dst=/app/instance flask-todo:1.0.0 python -c 'import wsgi; print("Таблицы SQLite подготовлены")'
    kind load docker-image flask-todo:1.0.0 --name cloud-lab2

Создать Secret и развернуть приложение:

    python3 scripts/create-secret.py
    kubectl apply -f k8s/00-namespace.yaml
    kubectl config set-context --current --namespace=cloud-lab2
    kubectl apply -f k8s/
    kubectl rollout status deployment/flask-todo --timeout=180s
    curl --max-time 10 -I http://127.0.0.1:8081/

## Доступ из браузера компьютера

В отдельном Git Bash компьютера:

    ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18081:127.0.0.1:8081 root@200.169.185.158

Оставить терминал открытым.
Адрес браузера: http://127.0.0.1:18081

Путь соединения:
порт 18081 компьютера → SSH → порт 8081 VPS →
порт 30080 узла → Service → порт 5000 выбранного Pod.

## Данные и ограничения

SQLite подключена к Pod через PVC в /app/instance.
На VPS данные находятся в /opt/cloud-practice/k8s-data/flask-todo.
Используется отдельная база, независимая от Docker Compose работы №1.

Реплики работают на одном узле и используют общий локальный том.
Это учебная схема для небольшой нагрузки, без отказоустойчивости узла.
При конкурентной записи SQLite возможны блокировки.

PV имеет политику Retain. Каталог базы не включён в Git.
Пользовательские данные не восстанавливаются из репозитория:
Git содержит приложение и конфигурацию, а не резервную копию базы.

## Выполненные обязательные проверки

- Узел Kubernetes перешёл в Ready.
- Приложение развёрнуто через kubectl apply -f k8s/.
- Две исходные реплики работают.
- Приложение доступно через Service и SSH-туннель.
- В браузере создана и отмечена выполненной задача.
- Масштабирование до трёх реплик проверено.
- Один Pod удалён; Kubernetes создал замену.
- Выполнены kubectl describe pod и kubectl logs.
- Приложение после проверок отвечает HTTP 200.
- Количество реплик возвращено к двум.
- Чтение Secret проверено без вывода его значения.

## Порядок показа преподавателю

1. Показать kubectl version и kubectl get nodes.
2. Показать файлы Deployment, Service, ConfigMap и хранилища.
3. Для Secret показать пример структуры и ссылку secretKeyRef,
   не раскрывая настоящее значение.
4. Показать kubectl get pods, services и deployments.
5. Открыть приложение в браузере и показать работу с задачами.
6. Получить индивидуальную карточку.
7. Выполнить её при преподавателе за 15 минут.
8. Показать результат и объяснить использованные механизмы.

Индивидуальные изменения заранее не подготовлены.

## Особенность VPS

Ранее наблюдалось зависание Docker, устранённое временным
изменением wbt_lat_usec на 0. После перезагрузки настройка
может сброситься; причина обсуждается с поддержкой провайдера.
Этот обход не является частью Dockerfile или Kubernetes-манифестов.
