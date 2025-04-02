#!/usr/bin/env bash
set -ou pipefail
cd "$(dirname "${0}")"

INPUT_DIR=roms-unverified
OUTPUT_DIR=roms-verified

time npx -y igir@latest \
  report \
  move \
  extract \
  test \
  -v \
  -d dats/ \
  -i "${INPUT_DIR}/" \
  -o "${OUTPUT_DIR}/" \
  --input-checksum-quick false \
  --input-checksum-min CRC32 \
  --input-checksum-max SHA256 \
  --only-retail \
  --single \
  --prefer-region GER,EUR,WORLD,JPN \
  --prefer-language DE,EN,JA \
  --prefer-revision newer
