#!/bin/bash
#SBATCH -J func_pfam
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH -o /public/home/ryx13/genome_cad/functional_annotation/logs/pfam_hmmscan.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/functional_annotation/logs/pfam_hmmscan.%j.err

set -euo pipefail

WORKDIR=/public/home/ryx13/genome_cad/functional_annotation
OUTDIR=${WORKDIR}/pfam
mkdir -p "${OUTDIR}" "${WORKDIR}/logs"
cd "${WORKDIR}"

HMMSCAN=/public/share/ac4w0a7em6/ryx13_software/hmmer-3.4-install/bin/hmmscan
HMMPRESS=/public/share/ac4w0a7em6/ryx13_software/hmmer-3.4-install/bin/hmmpress
QUERY=/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
PFAM=/public/home/ryx13/genome_cad/geta/pfam/Pfam-A.hmm
CPU=${SLURM_CPUS_PER_TASK:-32}

[[ -x "${HMMSCAN}" ]] || { echo "[ERROR] hmmscan not executable: ${HMMSCAN}" >&2; exit 1; }
[[ -x "${HMMPRESS}" ]] || { echo "[ERROR] hmmpress not executable: ${HMMPRESS}" >&2; exit 1; }
[[ -s "${QUERY}" ]] || { echo "[ERROR] protein FASTA not found: ${QUERY}" >&2; exit 1; }
[[ -s "${PFAM}" ]] || { echo "[ERROR] Pfam HMM not found: ${PFAM}" >&2; exit 1; }

if [[ ! -s "${PFAM}.h3f" || ! -s "${PFAM}.h3i" || ! -s "${PFAM}.h3m" || ! -s "${PFAM}.h3p" ]]; then
  echo "[INFO] Pfam HMM index missing. Running hmmpress at $(date)"
  "${HMMPRESS}" "${PFAM}"
fi

echo "[INFO] Pfam hmmscan started at $(date)"
"${HMMSCAN}" \
  --cpu "${CPU}" \
  --cut_ga \
  --domtblout "${OUTDIR}/Camptotheca_acuminata_T2T_vs_Pfam.domtblout" \
  --tblout "${OUTDIR}/Camptotheca_acuminata_T2T_vs_Pfam.tblout" \
  -o "${OUTDIR}/Camptotheca_acuminata_T2T_vs_Pfam.hmmscan.out" \
  "${PFAM}" \
  "${QUERY}"

echo "[INFO] Pfam hmmscan finished at $(date)"
