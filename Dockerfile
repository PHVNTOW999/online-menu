FROM python:3.12

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install Node.js 24 for frontend build (package.json requires >=24)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ${APP_HOME}
# install python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . ${APP_HOME}

# install frontend dependencies and build vendor/static assets
WORKDIR ${APP_HOME}/src
RUN npm install --legacy-peer-deps
RUN npm run build
WORKDIR ${APP_HOME}

# running migrations
RUN python manage.py migrate

# collect static files
RUN python manage.py collectstatic --noinput

# gunicorn
CMD ["gunicorn", "--config", "gunicorn-cfg.py", "config.wsgi"]
