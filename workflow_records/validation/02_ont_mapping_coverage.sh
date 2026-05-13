#!/usr/bin/env bash
set -euo pipefail

# ONT read remapping and coverage-breadth validation command records.

FASTA=/public/home/ryx13/genome_cad/juicer/run_3ddna/review/Ont_filt_asm.bp.p_ctg.top21.chr.seqkit.fasta
READS=/public/home/ryx13/genome_cad/hifiasm_ont/ONT_raw.filtlong.fastq.gz
OUTDIR=/public/home/ryx13/genome_cad/assembly_validation/ont_mapping
THREADS=32

MINIMAP2=/public/share/ac4w0a7em6/ryx13_software/micromamba/envs/centier_env/bin/minimap2
SAMTOOLS=/public/software/apps/samtools/1.9/gcc-7.3.1/bin/samtools

mkdir -p "${OUTDIR}"

"${MINIMAP2}" \
  -t "${THREADS}" \
  -ax map-ont \
  "${FASTA}" \
  "${READS}" \
  | "${SAMTOOLS}" sort \
      -@ "${THREADS}" \
      -o "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.sorted.bam" \
      -

"${SAMTOOLS}" index "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.sorted.bam"

"${SAMTOOLS}" flagstat \
  "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.sorted.bam" \
  > "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.flagstat.txt"

"${SAMTOOLS}" depth \
  -aa \
  "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.sorted.bam" \
  > "${OUTDIR}/ONT_raw.filtlong.to_T2T_top21.depth.tsv"

# The final per-chromosome breadth/depth summary deposited with the manuscript is:
# source_data/assembly_validation/ONT_filtered_reads_mapping_coverage.tsv
# It was generated from the depth table by summarizing covered bases, chromosome
# lengths and mean depth for each pseudomolecule.
