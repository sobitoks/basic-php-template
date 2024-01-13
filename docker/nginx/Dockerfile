FROM nginx:1.25.3-alpine

ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID appusergroup \
    && adduser -u $UID -G appusergroup --disabled-password --gecos "" -D appuser

COPY ./docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf