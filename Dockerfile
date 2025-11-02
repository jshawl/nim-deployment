FROM nimlang/nim:2.2.6-alpine-slim AS builder
RUN apk add --no-cache musl-dev
WORKDIR /app
COPY . .

# Build dynamically linked against musl
RUN nim c \
    -d:release \
    -d:ssl \
    --opt:size \
    --out:fetcher \
    src/fetcher.nim

# Use Alpine as runtime - matches the builder's libc
FROM alpine:latest
COPY --from=builder /app /app
EXPOSE 8080
ENTRYPOINT ["/app/fetcher"]