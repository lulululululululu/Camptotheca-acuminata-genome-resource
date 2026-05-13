#!/usr/bin/env bash
set -euo pipefail

# Hi-C scaffolding workflow using reused public Hi-C reads from SRR12042291.
# The FASTQ download and preprocessing records should be deposited together with
# the final workflow package when accession numbers are finalized.

JUICER_SCRIPT=/public/home/ryx13/genome_cad/juicer/run_juicer/juicer.hebhc.sh
JUICER_DIR=/public/home/ryx13/genome_cad/juicer/run_juicer
JUICER_SOFTWARE_DIR=/public/share/ac4w0a7em6/ryx13_software/juicer/SLURM
REFERENCE_FASTA=${JUICER_DIR}/references/ont_filt_asm.bp.p_ctg.fa
CHROM_SIZES=${JUICER_DIR}/references/ont_filt_asm.bp.p_ctg.chrom.sizes
RESTRICTION_SITES=${JUICER_DIR}/restriction_sites/assembly_DpnII.txt

"${JUICER_SCRIPT}" \
  -d "${JUICER_DIR}" \
  -D "${JUICER_SOFTWARE_DIR}" \
  -q hebhcnormal01 \
  -l hebhcnormal01 \
  -Q 24:00:00 \
  -L 72:00:00 \
  -z "${REFERENCE_FASTA}" \
  -p "${CHROM_SIZES}" \
  -y "${RESTRICTION_SITES}" \
  -s DpnII \
  -t 36 \
  --assembly

/public/share/ac4w0a7em6/ryx13_software/3d-dna/run-asm-pipeline.sh \
  -r 2 \
  /public/home/ryx13/genome_cad/juicer/run_juicer_v16/references/ont_filt_asm.bp.p_ctg.fa \
  /public/home/ryx13/genome_cad/juicer/run_juicer_v16/aligned/merged_nodups.txt

# After manual curation in Juicebox, run the post-review pipeline.
/public/share/ac4w0a7em6/ryx13_software/3d-dna/run-asm-pipeline-post-review.sh \
  -r /public/home/ryx13/genome_cad/juicer/run_3ddna/review/ont_filt_asm.bp.p_ctg.0.review.assembly \
  /public/home/ryx13/genome_cad/juicer/run_juicer_v16/references/ont_filt_asm.bp.p_ctg.fa \
  /public/home/ryx13/genome_cad/juicer/run_juicer_v16/aligned/merged_nodups.txt
