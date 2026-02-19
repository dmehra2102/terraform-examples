FROM golang:1.25-alpine AS builder
WORKDIR /src
COPY go.mod .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /app

FROM gcr.io/distroless/static-debian12:latest
COPY --from=builder /app /app
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT [ "/app" ]