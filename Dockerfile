FROM python:3.13-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server.py ./
COPY public ./public

ENV PYTHONUNBUFFERED=1
EXPOSE 8080

CMD ["python", "server.py"]
