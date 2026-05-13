#!/bin/bash
#SBATCH -J func_sprot
#SBATCH -p hebhcnormal03
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=80G
#SBATCH -o /public/home/ryx13/genome_cad/functional_annotation/logs/swissprot_diamond.%j.out
#SBATCH -e /public/home/ryx13/genome_cad/functional_annotation/logs/swissprot_diamond.%j.err

set -euo pipefail

WORKDIR=/public/home/ryx13/genome_cad/functional_annotation
OUTDIR=${WORKDIR}/swissprot
mkdir -p "${OUTDIR}" "${WORKDIR}/logs"
cd "${WORKDIR}"

DIAMOND=/public/share/ac4w0a7em6/ryx13_software/diamond
QUERY=/public/home/ryx13/genome_cad/geta/full_run/chr_liftover/Camptotheca_acuminata_T2T.protein.clean.fasta
DB=/public/home/ryx13/genome_cad/databases/functional_annotation/uniprot/uniprot_sprot.dmnd
CPU=${SLURM_CPUS_PER_TASK:-32}

[[ -x "${DIAMOND}" ]] || { echo "[ERROR] DIAMOND not executable: ${DIAMOND}" >&2; exit 1; }
[[ -s "${QUERY}" ]] || { echo "[ERROR] protein FASTA not found: ${QUERY}" >&2; exit 1; }
[[ -s "${DB}" ]] || { echo "[ERROR] Swiss-Prot DIAMOND DB not found: ${DB}" >&2; exit 1; }

echo "[INFO] Swiss-Prot DIAMOND started at $(date)"
"${DIAMOND}" blastp \
  --query "${QUERY}" \
  --db "${DB}" \
  --out "${OUTDIR}/Camptotheca_acuminata_T2T_vs_uniprot_sprot.diamond.tsv" \
  --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle \
  --evalue 1e-5 \
  --max-target-seqs 1 \
  --threads "${CPU}" \
  --sensitive

echo "[INFO] Swiss-Prot DIAMOND finished at $(date)"
