# Base image 
FROM python:3.14.0-alpine3.22

LABEL mantainer="carolkboabaid@gmail.com"

# If should save the .pyc files at the disk. # Yes 0, No 1
ENV PYTHONDONTWRITEBYTECODE=1

# The Python's output should be at the console and not saved at the buffer.
# In resume, you will see the output in real time.
ENV PYTHONUNBUFFERED=1

# Copy the folders inside the container
COPY ./app_imdb /django-imdb/app_imdb
COPY ./scripts /django-imdb/scripts
COPY ./requirements.txt /django-imdb/requirements.txt
COPY ./manage.py /django-imdb/manage.py

# Go inside of the folder in the container
WORKDIR /django-imdb

EXPOSE 8000

# Grouping the commands into a single RUN instruction can reduce the number of image 
# layers and make it more efficient.
#
# 1. Creates a virtual environment in /venv.
# 2. Upgrades pip
# 3. Installs Python dependencies from requirements.txt
# 4. Adds a non-root user (duser) to the Alpine Linux for better security
# 5. Adjusts permissions so duser can access /venv and execute the scripts
#
RUN python -m venv /venv && \
  /venv/bin/pip install --upgrade pip && \
  /venv/bin/pip install -r /django-imdb/requirements.txt && \
  adduser --disabled-password --no-create-home duser && \
  chown -R duser:duser /venv && \
  chmod -R +x /django-imdb/scripts

# Adds the folder scripts e venv/bin in the $PATH of the container
#
# When executing any command in Alpine Linux, the system will search for it in the PATH directories:
# first in '/scripts', then in '/venv/bin', and finally in the rest of the system PATH.
#
# PATH is an environment variable that defines where the shell looks for executable files.
# By setting /scripts:/venv/bin:$PATH, you prioritize these directories in the search order.
# Therefore, if there are commands with the same name, the one in /scripts will be executed first.
#
ENV PATH="/django-imdb/scripts:/venv/bin:$PATH"

# Change the user to the user
USER duser

# When the container starts, execute the file scripts/commands.sh
CMD ["commands.sh"]