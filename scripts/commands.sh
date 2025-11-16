#!/bin/sh

# Shuts down the execution of the scrip if a command fails
set -e

while ! nc -z psql $POSTGRES_PORT; do
  echo "🟡 Waiting for Postgres Database Startup (psql $POSTGRES_PORT) ..."
  sleep 2
done

echo "✅ Postgres Database Started Successfully (psql:$POSTGRES_PORT)"

python manage.py makemigrations --noinput
python manage.py migrate --noinput

echo "Setting superuser if not exists"

python manage.py shell << EOF 
import os 
from django.contrib.auth import get_user_model 

User = get_user_model() 
username = os.environ.get("DJANGO_SUPERUSER_USERNAME") 
email = os.environ.get("DJANGO_SUPERUSER_EMAIL") 
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD") 

if not User.objects.filter(username=username).exists(): 
  print("Creating superuser...") 
  User.objects.create_superuser(username, email, password) 
else: 
  print("Superuser already exists.")
EOF

echo "Starting the server..."

python manage.py runserver 0.0.0.0:8000