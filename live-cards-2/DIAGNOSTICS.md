# Быстрая диагностика перед защитой

Рабочая папка: /opt/cloud-practice/flask-todo-k8s.
Контекст: kind-cloud-lab2. Namespace: cloud-lab2.

```bash
kubectl config current-context
kubectl get nodes
kubectl get pods -n cloud-lab2 -o wide
kubectl get services -n cloud-lab2
kubectl get deployments -n cloud-lab2
kubectl get pvc -n cloud-lab2
kubectl get events -n cloud-lab2 --sort-by=.metadata.creationTimestamp
kubectl logs -n cloud-lab2 -l app=flask-todo --tail=30 --prefix=true
curl --max-time 10 -I http://127.0.0.1:8081/
```

Если на VPS HTTP 200, а браузер недоступен, проверь SSH-туннель компьютера:
локальный 18081 → удалённый 8081. Команду ssh -N выполняй в Git Bash компьютера, не внутри VPS.
Если локальный 18081 занят старым туннелем, используй действующее окно или заверши именно старый туннель через Ctrl+C.

Если Service не направляет запросы:

```bash
kubectl get endpointslices -n cloud-lab2 -l kubernetes.io/service-name=flask-todo
kubectl describe service flask-todo -n cloud-lab2
```

Если кластер недоступен:

```bash
systemctl is-active docker
timeout 15s docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
kind get clusters
```

Узлом служит Docker-контейнер cloud-lab2-control-plane. Остановка Docker затронет обе работы.
Временный WBT-обход на VPS может сброситься после перезагрузки. При повторном зависании продолжай диагностику и обращение в поддержку; не удаляй диск или /var/lib/docker.
Не удаляй namespace, PVC, PV или kind-кластер ради обычной ошибки приложения.

После масштабирования Terminating означает завершение Pod. Наблюдать: kubectl get pods -n cloud-lab2 -w; Ctrl+C завершает наблюдение.
Синтаксис crictl: docker exec cloud-lab2-control-plane crictl images. Параметра --name у images нет.

Меню только читает файлы; выход q. В less — q. В nano — Ctrl+O, Enter, Ctrl+X.
Если SSH оборвался во время работы в tmux: tmux attach -t k8s-work.

Документация:
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
https://kubernetes.io/docs/concepts/configuration/configmap/
https://kubernetes.io/docs/concepts/configuration/secret/
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
https://kind.sigs.k8s.io/docs/user/quick-start/
