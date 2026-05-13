#!/usr/bin/env bash
set -euo pipefail

# Hi-C heatmap plotting, centromere prediction and telomeric-repeat detection.

WORKDIR=/public/home/ryx13/genome_cad/juicer/run_3ddna/review
FASTA=${WORKDIR}/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta
MAMBA=/public/share/ac4w0a7em6/ryx13_software/bin/micromamba

# Hi-C heatmap.
"${MAMBA}" run -n plothic_env plothic \
  -hic "${WORKDIR}/ont_filt_asm.bp.p_ctg.final.hic" \
  -chr "${WORKDIR}/ont_filt_asm.bp.p_ctg.plothic.top21.length_order.chr.txt" \
  -o "${WORKDIR}/plothic_top21" \
  -g ont_filt_asm.bp.p_ctg.top21 \
  -r 25000 \
  -d observed \
  -n NONE \
  -log \
  -cmap YlOrRd \
  -format pdf \
  -f 16 \
  -dpi 600 \
  --bar-max 4 \
  -order

# Centromere prediction.
"${MAMBA}" run -n centier_env python /public/share/ac4w0a7em6/ryx13_software/CentIER/centIER.py \
  "${FASTA}" \
  -o "${WORKDIR}/centier_top21_chr" \
  -k 21 \
  --step_len 100000 \
  -c 200000 \
  --MINGAP 2 \
  --SIGNAL_THRESHOLD 0.7

# Telomeric-repeat detection.
TIDK=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/tidk_env/bin/tidk
TIDK_OUT=${WORKDIR}/tidk_top21_chr
mkdir -p "${TIDK_OUT}"

"${TIDK}" explore \
  --minimum 5 \
  --maximum 12 \
  "${FASTA}" \
  > "${TIDK_OUT}/top21_chr.tidk.explore.tsv"

"${TIDK}" search \
  --string TTTAGGG \
  --window 10000 \
  --output top21_chr_TTTAGGG \
  --dir "${TIDK_OUT}" \
  "${FASTA}"

"${TIDK}" plot \
  --tsv "${TIDK_OUT}/top21_chr_TTTAGGG_telomeric_repeat_windows.tsv" \
  --output "${TIDK_OUT}/top21_chr_TTTAGGG"
