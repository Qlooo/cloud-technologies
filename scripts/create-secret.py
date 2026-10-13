from pathlib import Path
import os
import secrets

project = Path(__file__).resolve().parents[1]
target = project / "k8s" / "20-secret.yaml"

content = f"""apiVersion: v1
kind: Secret
metadata:
  name: flask-todo-secret
  namespace: cloud-lab2
type: Opaque
stringData:
  FLASK_SECRET_KEY: "{secrets.token_hex(32)}"
"""

try:
    fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
except FileExistsError:
    print("Secret-файл уже существует; значение сохранено.")
else:
    with os.fdopen(fd, "w") as file:
        file.write(content)
    print("Secret-файл создан. Значение не выводится.")
