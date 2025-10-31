FROM alpine:3.19

RUN apk add --no-cache bash curl tzdata python3 py3-pip

WORKDIR /app

COPY entrypoint.sh backup.sh ./

RUN chmod +x entrypoint.sh backup.sh

ENV TZ=UTC
ENV INTERVAL_SECONDS=86400
ENV RUN_ON_START=true
ENV PORT=8080

# ติดตั้ง Python simple HTTP server สำหรับ render ไฟล์
EXPOSE ${PORT}

ENTRYPOINT ["/app/entrypoint.sh"]
