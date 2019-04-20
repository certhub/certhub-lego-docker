#!/bin/sh

set -e
set -u
set -x

git gau-ac \
git gau-xargs -I"{WORKDIR}" \
certhub-message-format "${CERTHUB_CERT_PATH}" x509 \
certhub-lego-run "${CERTHUB_CERT_PATH}" "${CERTHUB_CSR_PATH}" ~/.lego \
lego ${CERTHUB_LEGO_CHALLENGE_ARGS} ${CERTHUB_LEGO_ARGS} \
