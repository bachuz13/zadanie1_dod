# syntax=docker/dockerfile:1.4

FROM alpine AS downloader
WORKDIR /src
RUN apk add --no-cache git
RUN --mount=type=secret,id=git_token \
    git clone https://$(cat /run/secrets/git_token)@github.com/bachuz13/zadanie1.git .

FROM python:3.12-alpine AS builder
LABEL org.opencontainers.image.authors="Sebastian Żurawski"
WORKDIR /app
COPY --from=downloader /src/ /app/
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-alpine

WORKDIR /app
COPY --from=builder /install /usr/local
COPY --from=builder /app/app.py .

EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD wget -q --spider http://localhost:5000 || exit 1

CMD ["python", "app.py"]
