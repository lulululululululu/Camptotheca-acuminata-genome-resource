#!/bin/bash
#SBATCH -J func_eggnog
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH -o /public/home/ryx13/genome_cad/functional_annotation/logs/eggnog_mapper.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/functional_annotation/logs/eggnog_mapper.%j.err

set -euo pipefail

WORKDIR=/public/home/ryx13/genome_cad/functional_annotation
OUTDIR=${WORKDIR}/eggnog
LOGDIR=${WORKDIR}/logs
TMPDIR=${OUTDIR}/tmp
mkdir -p "${OUTDIR}" "${LOGDIR}" "${TMPDIR}"
cd "${WORKDIR}"

MAMBA=/public/share/ac4w0a7em6/ryx13_software/bin/micromamba
EGGNOG_ENV=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/eggnog_mapper
EMAPPER=${EGGNOG_ENV}/bin/emapper.py

QUERY=/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
DATA_DIR=/public/home/ryx13/genome_cad/databases/functional_annotation/eggnog
PREFIX=Camptotheca_acuminata_T2T_eggnog
CPU=${SLURM_CPUS_PER_TASK:-32}

[[ -x "${MAMBA}" ]] || { echo "[ERROR] micromamba not executable: ${MAMBA}" >&2; exit 1; }
[[ -d "${EGGNOG_ENV}" ]] || { echo "[ERROR] eggNOG-mapper environment not found: ${EGGNOG_ENV}" >&2; exit 1; }
[[ -x "${EMAPPER}" ]] || { echo "[ERROR] emapper.py not executable: ${EMAPPER}" >&2; exit 1; }
[[ -s "${QUERY}" ]] || { echo "[ERROR] protein FASTA not found: ${QUERY}" >&2; exit 1; }
[[ -s "${DATA_DIR}/eggnog.db" ]] || { echo "[ERROR] eggnog.db not found: ${DATA_DIR}/eggnog.db" >&2; exit 1; }
[[ -s "${DATA_DIR}/eggnog_proteins.dmnd" ]] || { echo "[ERROR] eggnog_proteins.dmnd not found: ${DATA_DIR}/eggnog_proteins.dmnd" >&2; exit 1; }
[[ -s "${DATA_DIR}/eggnog.taxa.db" ]] || { echo "[ERROR] eggnog.taxa.db not found: ${DATA_DIR}/eggnog.taxa.db" >&2; exit 1; }

echo "[INFO] eggNOG-mapper started at $(date)"
echo "[INFO] query: ${QUERY}"
echo "[INFO] data_dir: ${DATA_DIR}"
echo "[INFO] output_dir: ${OUTDIR}"
echo "[INFO] cpus: ${CPU}"

"${MAMBA}" run -p "${EGGNOG_ENV}" "${EMAPPER}" \
  -i "${QUERY}" \
  --itype proteins \
  -m diamond \
  --data_dir "${DATA_DIR}" \
  --cpu "${CPU}" \
  --output "${PREFIX}" \
  --output_dir "${OUTDIR}" \
  --temp_dir "${TMPDIR}" \
  --override

echo "[INFO] eggNOG-mapper finished at $(date)"
echo "[INFO] Main annotation output: ${OUTDIR}/${PREFIX}.emapper.annotations"
