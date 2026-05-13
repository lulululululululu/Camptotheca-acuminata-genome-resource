#!/usr/bin/env bash
set -euo pipefail

# Initial ONT assembly with hifiasm.

HIFIASM=/public/share/ac4w0a7em6/ryx13_software/hifiasm/hifiasm
FILTERED_FASTQ=/public/home/ryx13/genome_cad/hifiasm_ont/ONT_raw.filtlong.fastq.gz
OUT_PREFIX=/public/home/ryx13/genome_cad/hifiasm_ont/ont_filt_asm
THREADS=32

"${HIFIASM}" \
  -o "${OUT_PREFIX}" \
  -t "${THREADS}" \
  --ont \
  "${FILTERED_FASTQ}"
