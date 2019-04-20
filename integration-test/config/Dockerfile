FROM alpine:latest

ARG common_name
ENV common_name ${common_name}

ARG csr_path
ENV csr_path ${csr_path}

RUN apk add openssl && \
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out /etc/ssl/private/key.pem && \
    mkdir -p "$(dirname ${csr_path})" && \
    openssl req -new -subj "/CN=${common_name}/" -key /etc/ssl/private/key.pem -out ${csr_path}
