FROM python:3.14-rc-alpine3.19

RUN apk upgrade --no-cache

WORKDIR /app
COPY server.py ./
COPY public ./public

ENV PYTHONUNBUFFERED=1
EXPOSE 8080

CMD ["python", "server.py"]
