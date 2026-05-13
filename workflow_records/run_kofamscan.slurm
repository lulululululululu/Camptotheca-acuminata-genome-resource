#!/bin/bash
#SBATCH -J func_kofam
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH -o /public/home/ryx13/genome_cad/functional_annotation/logs/kofamscan.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/functional_annotation/logs/kofamscan.%j.err

set -euo pipefail

WORKDIR=/public/home/ryx13/genome_cad/functional_annotation
OUTDIR=${WORKDIR}/kofam
LOGDIR=${WORKDIR}/logs
TMPDIR=${OUTDIR}/tmp
mkdir -p "${OUTDIR}" "${LOGDIR}" "${TMPDIR}"
cd "${WORKDIR}"

MAMBA=/public/share/ac4w0a7em6/ryx13_software/bin/micromamba
KOFAM_ENV=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/kofamscan
KOFAM_SCAN=/public/share/ac4w0a7em6/ryx13_software/kofam_scan/kofam_scan-master/exec_annotation

QUERY=/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
KOFAM_DB=/public/home/ryx13/genome_cad/databases/functional_annotation/kofam
PROFILES=${KOFAM_DB}/profiles
KO_LIST=${KOFAM_DB}/ko_list
CPU=${SLURM_CPUS_PER_TASK:-32}

DETAIL_OUT=${OUTDIR}/Camptotheca_acuminata_T2T_vs_Kofam.detail.tsv
MAPPER_OUT=${OUTDIR}/Camptotheca_acuminata_T2T_vs_Kofam.mapper.tsv

[[ -x "${MAMBA}" ]] || { echo "[ERROR] micromamba not executable: ${MAMBA}" >&2; exit 1; }
[[ -d "${KOFAM_ENV}" ]] || { echo "[ERROR] KofamScan environment not found: ${KOFAM_ENV}" >&2; exit 1; }
[[ -x "${KOFAM_SCAN}" ]] || { echo "[ERROR] KofamScan exec_annotation not executable: ${KOFAM_SCAN}" >&2; exit 1; }
[[ -s "${QUERY}" ]] || { echo "[ERROR] protein FASTA not found: ${QUERY}" >&2; exit 1; }
[[ -d "${PROFILES}" ]] || { echo "[ERROR] Kofam profiles directory not found: ${PROFILES}" >&2; exit 1; }
[[ -s "${KO_LIST}" ]] || { echo "[ERROR] Kofam ko_list not found: ${KO_LIST}" >&2; exit 1; }

echo "[INFO] KofamScan started at $(date)"
echo "[INFO] query: ${QUERY}"
echo "[INFO] profiles: ${PROFILES}"
echo "[INFO] ko_list: ${KO_LIST}"
echo "[INFO] output_dir: ${OUTDIR}"
echo "[INFO] tmp_dir: ${TMPDIR}"
echo "[INFO] cpus: ${CPU}"

"${MAMBA}" run -p "${KOFAM_ENV}" "${KOFAM_SCAN}" \
  -p "${PROFILES}" \
  -k "${KO_LIST}" \
  --cpu "${CPU}" \
  --tmp-dir "${TMPDIR}" \
  -f detail-tsv \
  -o "${DETAIL_OUT}" \
  "${QUERY}"

echo "[INFO] KofamScan detail-tsv output finished at $(date)"

"${MAMBA}" run -p "${KOFAM_ENV}" "${KOFAM_SCAN}" \
  -p "${PROFILES}" \
  -k "${KO_LIST}" \
  --cpu "${CPU}" \
  --tmp-dir "${TMPDIR}" \
  -f mapper-one-line \
  -r \
  -o "${MAPPER_OUT}" \
  "${QUERY}"

echo "[INFO] KofamScan mapper-one-line output finished at $(date)"
echo "[INFO] Detail output: ${DETAIL_OUT}"
echo "[INFO] Mapper output: ${MAPPER_OUT}"
