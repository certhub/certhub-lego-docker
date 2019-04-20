#!/bin/sh

set -e
set -u
set -x

CONFIG_CSR_DIR=$(dirname "${CONFIG_CSR_PATH}")
mkdir -p "${CONFIG_CSR_DIR}"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 | \
    openssl req -new -subj "/CN=${CONFIG_CERT_CN}/" -key - -out "${CONFIG_CSR_PATH}"
