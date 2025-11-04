FROM nimlang/nim:2.2.6-alpine-regular AS builder
RUN apk add --no-cache musl-dev
WORKDIR /app
COPY . .
RUN nimble install db_connector
RUN nim c \
    -d:release \
    -d:danger \
    -d:ssl \
    --opt:size \
    --passC:-flto \
    --passL:-flto \
    --out:fetcher \
    src/fetcher.nim
RUN strip --strip-all fetcher
FROM gcr.io/distroless/static
COPY --from=builder /app/fetcher /app/fetcher
COPY --from=builder /usr/lib/libsqlite3.so.0 /usr/lib/
COPY --from=builder /lib/ld-musl-*.so.1 /lib/
COPY --from=builder /usr/lib/libcrypto.so.3 /usr/lib/
COPY --from=builder /usr/lib/libssl.so.3 /usr/lib/
WORKDIR /app