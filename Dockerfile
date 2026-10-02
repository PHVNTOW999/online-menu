FROM python:3.12

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY requirements.txt ${APP_HOME}
# install python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . ${APP_HOME}

# Делаем entrypoint.sh исполняемым и задаем его как точку входа
RUN chmod +x ${APP_HOME}/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

# gunicorn
CMD ["gunicorn", "--config", "gunicorn-cfg.py", "config.wsgi"]
