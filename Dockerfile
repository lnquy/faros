FROM alpine:3.7

COPY faros /faros

EXPOSE 9999
ENTRYPOINT ["/faros"]
