# Практическая №2 — порядок показа

Все блоки — команды VPS, кроме явно отмеченных команд компьютера.
Меню только показывает текст. Не копируй весь файл как скрипт.

## Подключение

В Git Bash компьютера:

```bash
ssh root@200.169.185.158
```

На VPS:

```bash
cd /opt/cloud-practice/flask-todo-k8s
kubectl config use-context kind-cloud-lab2
kubectl config set-context --current --namespace=cloud-lab2
git branch --show-current
```

Ожидаем ветку cloud-lab-2. Версия работы №1 находится в другой папке:
/opt/cloud-practice/flask-todo. Не переключай её ветку для работы №2.

## 1. Показать Kubernetes-кластер

```bash
kind version
kind get clusters
kubectl version
kubectl get nodes -o wide
```

Ожидается cloud-lab2-control-plane со статусом Ready.
Что сказать: «Использую разрешённый заданием kind. Кластер локален относительно VPS, его узел работает в Docker; команды выполняю по SSH».
Один узел может запускать несколько Pod. Увеличение реплик не добавляет узлов.

## 2. Показать конфигурацию

```bash
cat infra/kind.yaml
cat k8s/40-deployment.yaml
cat k8s/50-service.yaml
cat k8s/10-configmap.yaml
cat infra/secret.example.yaml
cat k8s/30-storage.yaml
cat wsgi.py
```

Deployment задаёт две реплики и образ flask-todo:1.0.0.
Service выбирает Pod по метке app=flask-todo.
ConfigMap задаёт GUNICORN_CMD_ARGS для Gunicorn.
Secret передаёт FLASK_SECRET_KEY через secretKeyRef.
wsgi.py загружает FLASK_ настройки в конфигурацию Flask.
PV/PVC подключают SQLite к /app/instance.

Настоящий Secret не показывай через cat. Структуру показывай по примеру.

```bash
git check-ignore k8s/20-secret.yaml
git ls-files k8s/20-secret.yaml
kubectl get secret flask-todo-secret
```

check-ignore выводит путь; ls-files ничего не выводит; get secret показывает тип и число ключей, без их значений.

## 3. Показать развёртывание и ресурсы

В подготовленном кластере и при наличии локального Secret-файла:

```bash
kubectl apply -f k8s/
kubectl rollout status deployment/flask-todo --timeout=180s
kubectl get pods -o wide
kubectl get services
kubectl get deployments
kubectl get pvc
kubectl get pv
```

Ожидаются два Pod 1/1 Running, Deployment 2/2, хранилище Bound.
Повторный apply возвращает декларативные значения файлов: например, replicas: 2.
Не применяй всю исходную папку после live-изменения, если хочешь сохранить его результат.
В imagePullPolicy: Never требуется образ внутри узла, а не только в Docker VPS.

```bash
docker exec cloud-lab2-control-plane crictl images
```

В списке найди docker.io/library/flask-todo с тегом 1.0.0.
Для чтения Secret без вывода значения:

```bash
kubectl exec deployment/flask-todo -- python -c 'from wsgi import app; print("Secret прочитан Flask:", bool(app.config["SECRET_KEY"]))'
```

## 4. Показать приложение

На VPS:

```bash
curl --max-time 10 -I http://127.0.0.1:8081/
```

Ожидаем HTTP 200. В отдельном Git Bash КОМПЬЮТЕРА:

```bash
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18081:127.0.0.1:8081 root@200.169.185.158
```

Окно оставить открытым. Отсутствие приглашения shell после ввода пароля нормально для -N.
Открыть http://127.0.0.1:18081 . Добавить непустую задачу и показать Update.
Трафик: 18081 компьютера → SSH → 8081 VPS → 30080 узла → Service → 5000 Pod.
Это Service обеспечивает выбор Pod; туннель только передаёт соединения.

## 5. Показать выполненные обязательные проверки

Во время подготовки подтверждены 2 → 3 реплики, удаление одного Pod и создание замены, describe и logs. После проверок восстановлены две реплики.
Можно показать сохранённые скриншоты; повторять изменения до выдачи карточки без необходимости не нужно.
Для текущей диагностики:

```bash
cloud_show_pod=$(kubectl get pods -l app=flask-todo -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$cloud_show_pod"
kubectl logs "$cloud_show_pod" --tail=30
```

## 6. Получить индивидуальную карточку

```bash
bash live-menu-2.sh
```

Введи номер 1–10. Прочитай условия, выполни необходимые изменения при преподавателе, покажи результат и объясни механизм.
Справочные файлы не создают изменённые Deployment, новые образы или готовые исправления.

## Краткое объяснение

«Я развернул Flask Todo в kind на VPS. Deployment управляет репликами через ReplicaSet, Service предоставляет доступ к Pod. Обычные настройки вынесены в ConfigMap, ключ Flask — в Secret. SQLite находится в PVC. Масштабирование, автоматическую замену удалённого Pod и диагностику проверил. Это учебный кластер с одним узлом и общей локальной SQLite-базой».

Полный первоначальный запуск описан в PRACTICE-2.md: пункт c меню.
