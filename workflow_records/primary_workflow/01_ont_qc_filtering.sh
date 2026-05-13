#!/usr/bin/env bash
set -euo pipefail

# ONT read quality control and filtering.
# Replace the paths below with local paths before rerunning.

RAW_FASTQ=/home/ryx/xishu_genge/ONT_data/ON20250724GWUL_sup.fastq.gz
OUTROOT=/home/ryx/xishu_genge/ONT_data/raw_qc
THREADS=8

mkdir -p \
  "${OUTROOT}/nanostat_raw" \
  "${OUTROOT}/nanoplot_raw" \
  "${OUTROOT}/filtlong" \
  "${OUTROOT}/nanostat_filt" \
  "${OUTROOT}/nanoplot_filt"

NanoStat \
  --fastq "${RAW_FASTQ}" \
  --outdir "${OUTROOT}/nanostat_raw" \
  -n ONT_raw

NanoPlot \
  --fastq "${RAW_FASTQ}" \
  -o "${OUTROOT}/nanoplot_raw" \
  -p ONT_raw \
  -t "${THREADS}" \
  --tsv_stats \
  --huge

filtlong \
  --min_length 1000 \
  --keep_percent 90 \
  "${RAW_FASTQ}" \
  | gzip > "${OUTROOT}/filtlong/ONT_raw.filtlong.fastq.gz"

NanoStat \
  --fastq "${OUTROOT}/filtlong/ONT_raw.filtlong.fastq.gz" \
  --outdir "${OUTROOT}/nanostat_filt" \
  -n ONT_filtlong

NanoPlot \
  --fastq "${OUTROOT}/filtlong/ONT_raw.filtlong.fastq.gz" \
  -o "${OUTROOT}/nanoplot_filt" \
  -p ONT_filtlong \
  -t "${THREADS}" \
  --tsv_stats \
  --huge
