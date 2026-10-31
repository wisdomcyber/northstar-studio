FROM python:3.13-slim

WORKDIR /app
COPY server.py ./
COPY public ./public

ENV PYTHONUNBUFFERED=1
EXPOSE 8080

CMD ["python", "server.py"]
