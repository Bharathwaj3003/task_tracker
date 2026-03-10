from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2
import os

app = FastAPI()

conn = psycopg2.connect(
    host=os.getenv("DB_HOST", "localhost"),
    database="tasks",
    user="postgres",
    password="postgres"
)

cur = conn.cursor()
cur.execute("""
CREATE TABLE IF NOT EXISTS tasks(
id SERIAL PRIMARY KEY,
title TEXT,
description TEXT
)
""")
conn.commit()


class Task(BaseModel):
    title: str
    description: str


@app.post("/tasks")
def create_task(task: Task):
    cur.execute(
        "INSERT INTO tasks(title,description) VALUES (%s,%s)",
        (task.title, task.description)
    )
    conn.commit()

    return {"status": "created"}


@app.get("/tasks")
def list_tasks():
    cur.execute("SELECT * FROM tasks")
    rows = cur.fetchall()
    return rows