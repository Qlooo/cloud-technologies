from app import app, db

app.config.from_prefixed_env()

with app.app_context():
    db.create_all()
