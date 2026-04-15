# Builder stage
FROM python:3.8-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends git gcc python3-dev && rm -rf /var/lib/apt/lists/*

ENV APP_HOME=/microservice/
WORKDIR $APP_HOME

ADD requirement*.txt $APP_HOME/
RUN pip wheel --no-cache-dir --wheel-dir /usr/src/app/wheels -r requirements-docker.txt --pre

# Runner stage
FROM python:3.8-slim

ENV PYTHONUNBUFFERED=1 APP_HOME=/microservice/
ENV CONFIGMAP_FILE="${APP_HOME}config-docker.yml"

RUN mkdir -p $APP_HOME && useradd -m -r python && chown -R python $APP_HOME
WORKDIR $APP_HOME

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /microservice/requirement*.txt ./

RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements-docker.txt --pre

ADD . $APP_HOME
RUN chown -R python $APP_HOME

EXPOSE 8080
USER python

ENTRYPOINT ["python", "manage.py"]