FROM golang:bullseye as builder

RUN apt-get update && apt-get install -y ca-certificates openssl

ARG cert_location=/usr/local/share/ca-certificates

# Get certificate from "github.com"
RUN openssl s_client -showcerts -connect github.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > ${cert_location}/github.crt
# Get certificate from "proxy.golang.org"
RUN openssl s_client -showcerts -connect sum.golang.org:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/sum.golang.crt
# Update certificates
RUN update-ca-certificates

COPY *.go $GOPATH/src/mypackage/myapp/
WORKDIR $GOPATH/src/mypackage/myapp/
RUN go mod init && go mod tidy -compat=1.17
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/docker_state_exporter

FROM alpine:3
COPY --from=builder /go/bin/docker_state_exporter /go/bin/docker_state_exporter
EXPOSE 8080
ENTRYPOINT ["/go/bin/docker_state_exporter"]
CMD ["-listen-address=:8080"]
