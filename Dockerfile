FROM alpine:edge
RUN apk add --no-cache shellcheck bash make
WORKDIR /root
COPY ./ ./
CMD [ "bash" ]
